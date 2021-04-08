#!/bin/bash

# script version: v2.2020.0527A bugfix edition
# NOTE - check this code for EDITME and modify according to your environment

# RUN AS ROOT - tested on Linux Mint / Ubuntu 18.04 and 20.04 (rpool), should be fairly easily adaptable
# Pass arg $1 = "cleanup" to delete test encryption datasets / cleanup ramdisk

# REF: https://github.com/openzfs/zfs/issues/10363
# REF: https://www.cyberciti.biz/faq/how-to-find-out-aes-ni-advanced-encryption-enabled-on-linux-system/

##Check for root priviliges
if [ "$(id -u)" -ne 0 ]; then
   echo "Please run $0 as root."
   exit 1
fi

# if we on OSX, you running the wrong version of this script
# ex. OSTYPE=darwin17.7.0
if [ $(echo $OSTYPE |grep -c darwin) -gt 0 ]; then
  echo "You need to be running this on a non-OSX (e.g. Linux) box. There is an OSX version of this script available."
  exit 10
fi


# DEFINE VARS
zp=rpool # EDITME # NOTE this zpool is SSD-based 

logfile=~/zfs-test-encryption-speeds.log

# will be copied to ramdisk (prep) - put "" to skip 
# NOTE nothing prevents you from copying an .iso over SMB or NFS ;-)
isofile=/zdell500/shrcompr/ISO/bionic-desktop-amd64.iso # EDITME
#isofile="/mnt/imac5/ISO/bionic-desktop-amd64.iso" # EDITME
#isofile=""

compr=lz4

# where are we storing the key for these test datasets (will be created if not exist)
zfskeyloc=~/zek-testencr-zfs.key

#=====================================
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Echo something to current console AND log
# Can also handle piped input ( cmd |logecho )
# Warning: Has trouble echoing '*' even when quoted.
function loggit () {
  args=$@

  if [ -z "$args" ]; then
    args='tmp'

    while [ 1 ]; do
      read -e -t2 args

      if [ -n "$args" ]; then
         echo "$args" |tee -a $logfile;
      else
        break;
      fi
    done

  else
    echo "$args" |tee -a $logfile;
  fi
} # END FUNC

function ridmeofthesedatasets () {
  loggit "$0 - `date` - Cleanup called"
  if [ "$zp" = "rpool" ]; then
    cd /
  else
    cd /$zp || failexit 404 "! Cleanup failed - /$zp not found"
  fi
  for zdel in `echo Test-aes*`; do loggit "$0 - Destroying encryption test dataset: $zp/$zdel"; time zfs destroy -rv "$zp/$zdel"; done

  # need only filename, not path - strippit
  isofile2=$(basename "$isofile")
  C_ALL=C; declare -i chklen # integer
  chklen=$(echo ${#isofile2})
  if [ $chklen -gt 0 ] && [ -e "/dev/shm/$isofile2" ]; then
    loggit "Cleaning up $isofile2 from ramdisk"
   /bin/rm -f "/dev/shm/$isofile2"
  fi  # sanity, will give error if we try to remove /dev/shm if var=blank
  
  df -hT |head -n 1
  df -hT |grep $zp
  df -hT |grep /dev/shm
  exit;
}

[ "$1" = "cleanup" ] && ridmeofthesedatasets


# MAIN ====================================================================
mv -v $logfile $logfile-old 2>/dev/null

echo "`date` - `hostname` - BEGIN encryption speed tests" |tee $logfile

loggit "o Kernel: `uname -r`" 
loggit "o Zpool version: $(zpool version)"
loggit "$(dmesg |grep ZFS)"
loggit "o CPU detected: $(grep -m1 "model name" /proc/cpuinfo |awk -F: '{print $2}')"
loggit "o Number of CPU cores/hyperthreads: $(grep -c 'processor' /proc/cpuinfo)"
loggit "o Actual number of $(grep -m1 cores /proc/cpuinfo)"
loggit "o CPU supports AES acceleration (blank=NO): $(grep -m1 -o aes /proc/cpuinfo)"
loggit "o Crypto modules loaded:"
loggit "$(sort -u /proc/crypto |grep module)"

loggit "o Check for openssl / run benchmarks"
which openssl && loggit "$(openssl speed aes)"
loggit "o Check for cryptsetup - please wait, this will take a few"
which cryptsetup && loggit "$(cryptsetup benchmark)"

loggit "o PREP - Copy ~1GB iso file to ramdisk if not already there" 
LC_ALL=C; declare -i chklen # integer
chklen=$(echo ${#isofile})
[ $chklen -gt 0 ] && [ -e /dev/shm ] && [ -e "$isofile" ] && time cp -vn "$isofile" /dev/shm |tee -a $logfile
[ -e "/dev/shm/*.iso" ] || loggit "o Skipped ISO -> RAMdisk"

# get current zfs supported encryption types (NOTE depends on up-to-date man page) - output commasep
# yes, this is 3 different replace methods ;-) who doesn't like to show off a bit now and then
# read zfs man page, get ciphers, change pipe to comma, blank out unnec. stuff

encrline=$(man zfs|grep "encryption=" |head -n 1 |sed 's/|/,/g') # |sed 's/off,on,//g')
# NOTE on/off is REVERSED from osx manpage(!) so we process differently below in case they change it to match
encrline=$(echo "$encrline" |tr -d '[:space:]') # strip blanks
encrline=${encrline/on,/}    # bash inline sed, replace string with blank
encrline=${encrline/off,/}
encrline=${encrline/encryption=/}   

loggit "o Supported ZFS encryption types (per ' man zfs ')"
loggit "$encrline"
# we expect something like:
#aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm

# REF: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash#tab-top
# read string into bash array
oIFS="$IFS"
IFS=","
declare -a encrtype=($encrline)
IFS="$oIFS"
unset oIFS

#generate 32 byte passkey ONLY if not already exist
[ -e $zfskeyloc ] || dd if=/dev/urandom of="$zfskeyloc" bs=1 count=32

# NOTE omit xattr=sa for freebsd as of 2020.0526, may change after support is added to their code
# NOTE relatime and acltype=posixacl are missing from OSX zfs port as of 2020.0526
for testencr in "${encrtype[@]}"; do
  loggit "o Creating $zp dataset for $testencr (if it doesnt already exist)"
  
#  [ -e /$zp/Test-$testencr ] || \ # fails on rpool
  [ $(df |grep -c Test-$testencr) -gt 0 ] || \
  zfs create -o \
    atime=off -o relatime=off -o compression=$compr -o sharesmb=off -o recordsize=1024k \
    -o encryption=$testencr \
    -o keyformat=raw \
    -o keylocation=file://"$zfskeyloc" \
    -o acltype=posixacl -o normalization=formD \
    -o xattr=sa \
    $zp/Test-$testencr || failexit 99 "! Failed to create ZFS $zp/$testencr"

    loggit "$(zfs get encryption,keylocation $zp/Test-$testencr)"
done
    
#sync # may not want to do this if you have a long e.g.  backup process running

free
echo 1 > /proc/sys/vm/drop_caches # free pagecache
free

df -hT |head -n 1
df -hT |grep -v '/ROOT/' |grep $zp
df -hT |grep /dev/shm
ls -lh /dev/shm/*.iso

loggit "`date` $0 - $(hostname) - Ready for testing" # from here you can test how long it takes to copy iso file, run fio, etc
# time (cp -v $isofile /$zp/aesdataset; sync)

echo "o $0 Logfile is: $logfile"

exit;


#################################################

2020.0526 Author: Kneutron - knocked together a zfs test script to create datasets per encryption type
Tested OK on Ubuntu 18.04 / Linux Mint

# Future changes will be in reverse-date order

2020.0527 v2A - bugfix edition, chklen was ($ instead of $(
2020.0527 V2 - fixed minor bug in cleanup to fail if cant cd to /$zp, cd "/" if zp=rpool
sanity - fixed check length of isofile var, skip if 0
zp=rpool related fixes
+ added ramdisk cleanup + sanity checks (will ONLY delete defined iso file)
+ tested on ubuntu 20.04 with zfs rpool


NOTE if reboot or $thing happens to zpool such as export,  you may need to:

 zfs load-key $zp/encrtype
 zfs mount -a

NOTE if doing this on an ssd-based pool, you may want to "zpool trim $zp" after doing cleanup


# note this does not work on osx (fixed in osx port) - REF: https://stackoverflow.com/questions/41489692/how-to-search-linux-man-pages-e-g-with-grep
$ man zfs|grep "encryption=" |head -n 1 |sed 's/|/,/g' |sed 's/off,on,//g'
     encryption=off|on|aes-128-ccm|aes-192-ccm|aes-256-ccm|aes-128-gcm|aes-192-gcm|aes-256-gcm
     
     encryption=off,on,aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm
     
     encryption=aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm

/zmsata480 # for z in `echo aes*`; do echo $z; zfs destroy zmsata480/$z;done

