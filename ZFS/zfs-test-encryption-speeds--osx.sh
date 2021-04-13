#!/opt/local/bin/bash
# macports bash5

#BANG/usr/local/bin/bash 
# bash5 from brew

# xxx 2020.0526 mod for OSX - requires file-based pool if zpool was created with dual-boot-compatible options
# -> check with ' zpool upgrade ' or ' zpool get all |grep encryption ' - if encryption is missing, you need ^^

# NOTE - relies on (macports or brew) gnu "coreutils" being installed as well as updated bash v5
# REF: https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/

# RUN AS ROOT - tested on OSX High Sierra 10.13 with ZFS zfs-1.9.4-0 / zfs-kmod-1.9.4-0
# Pass arg $1 = "cleanup" to delete test encryption datasets

# REF: https://github.com/openzfs/zfs/issues/10363
# REF: https://www.cyberciti.biz/faq/how-to-find-out-aes-ni-advanced-encryption-enabled-on-linux-system/

##Check for root priviliges
if [ "$(id -u)" -ne 0 ]; then
   echo "Please run $0 as root."
   exit 1
fi

# if we not on OSX, you running the wrong version of this script
# ex. OSTYPE=darwin17.7.0
if [ $(echo $OSTYPE |grep -c darwin) -ne 1 ]; then
  echo "You need to be running this on an OSX box. There is a Linux version of this script available."
  exit 10
fi


# DEFINE VARS
#zp=zfilepool # EDITME # NOTE this zpool is FILE-based due to dual-boot pool compatibility 
zp=zint500 # EDITME # NOTE this zpool is FILE-based due to dual-boot pool compatibility 

logfile=~/zfs-test-encryption-speeds.log

# will be copied to ramdisk (prep) - put "" to skip - # EDITME
#isofile=/Volumes/zsgtera2B/shrcompr-zsgt2B/ISO/bionic-desktop-amd64.iso
isofile=/Volumes/zsgtera2B/shrcompr-zsgt2B/ISO/KNOPPIX_V8.6-2019-08-08-EN.iso
#isofile=""

compr=lz4

#ramdisksize=1200 # MB  # EDITME based on size of ISO file +200MB
ramdisksize=4900 # MB  # EDITME based on size of ISO file +200MB
# recommended for systems with 8GB+ RAM, or have NO apps running 
# - will auto-skip if RAM <6GB or if set to 0

# check ram size, skip if too low
# REF: https://serverfault.com/questions/112711/how-can-i-get-cpu-count-and-total-ram-from-the-os-x-command-line
rammstein=$(system_profiler SPHardwareDataType |grep "  Memory:" |awk '{print $2}') # result is in GB
#      Memory: 20 GB
[ $rammstein -lt 6 ] && let ramdisksize=0 && loggit "! Warning - SKIPPING RAMDISK - INSTALLED RAM IS LESS THAN 6GB"
#|| [ $ramdisksize -eq 0 ] ## checks later

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

function osxmkramdisk () {
# tested in High Sierra osx 10.13
# REF: https://stackoverflow.com/questions/46224103/create-apfs-ram-disk-on-macos-high-sierra
# REF for previous versions of OSX: https://osxdaily.com/2007/03/23/create-a-ram-disk-in-mac-os-x/
  [ $ramdisksize = 0 ] && loggit "! Warning - SKIPPING RAMDISK" && return;

  loggit "o Creating RAMDISK of $ramdisksize MB"  
  let blox=$ramdisksize*2048
  diskisat=$(hdid -nomount ram://$blox)
  time diskutil erasedisk hfs+ ramdisk $diskisat || loggit "o Warning code 120 - Failed to create ramdisk, continuing without it"
# /dev/disk9s1    hfs   1.1G   13M  1.1G   2% /Volumes/ramdisk
# df -k
#Filesystem        1024-blocks      Used Available Capacity iused      ifree %iused  Mounted on
#/dev/disk9s1          1097688     12336   1085352     2%       4 4294967275    0%   /Volumes/ramdisk

# NOTE - To destroy the RAM disk again, call 
# diskutil eject <output path of previous hdid command> # e.g. diskutil eject /dev/disk2
# umount /Volumes/ramdisk
# hdiutil detach /dev/diskX
}

function ridmeofthesedatasets () {
  cd /Volumes/$zp
  loggit "$0 - `date` - Cleanup called"

  for zdel in `echo Test-aes*`; do loggit "$0 - Destroying encryption test dataset: $zp/$zdel"; time zfs destroy -rv $zp/$zdel; done
  diskutil eject /Volumes/ramdisk && loggit "$0 - RAMdisk ejected"
  
  gdf -hT |head -n 1
  gdf -hT |grep $zp
  exit;
}

# Utility calls
[ -e /Volumes/ramdisk ] || osxmkramdisk

[ "$1" = "cleanup" ] && ridmeofthesedatasets


# MAIN ====================================================================
# REFS:
# https://apple.stackexchange.com/questions/341525/use-osx-terminal-to-find-out-the-cpu-instructions-set-avx-sse-and-such
# https://apple.stackexchange.com/questions/352769/does-macos-have-a-command-to-retrieve-detailed-cpu-information-like-proc-cpuinf
# https://serverfault.com/questions/112711/how-can-i-get-cpu-count-and-total-ram-from-the-os-x-command-line
# https://osxdaily.com/2010/08/03/list-all-third-party-kernel-extensions/

mv -v $logfile $logfile-old 2>/dev/null

echo "$(date) - $(hostname) - BEGIN encryption speed tests" |tee $logfile

loggit "o Kernel: $(uname -r)" 
loggit "o Zpool version: $(zpool version)"
#loggit "$(dmesg |grep ZFS)"
loggit "ZFS kext module version: $(kextstat|grep zfs |awk '{print $6 $7}')"
#net.lundman.zfs(1.9.4)

loggit "o CPU detected: $(system_profiler SPHardwareDataType |egrep 'Processor Name|Processor Speed|Number of Processors|Cores')"
#loggit "o CPU detected: $(grep -m1 "model name" /proc/cpuinfo |awk -F: '{print $2}')"
#loggit "o Number of CPU cores/hyperthreads: $(grep -c 'processor' /proc/cpuinfo)"
#loggit "o Actual number of $(grep -m1 cores /proc/cpuinfo)"
loggit "o CPU supports AES acceleration (blank=NO): $(sysctl -a |grep -i aes)"

loggit "o Check for openssl / run benchmarks"
which openssl && loggit "$(openssl speed aes)"

# NOTE VeraCrypt (avail in macports and brew) - PROTIP macports find install path by starting gui app, rt-click, show in Finder 
if [ -e /Applications/MacPorts/VeraCrypt.app/Contents/MacOS/VeraCrypt ]; then
  loggit "o VeraCrypt is installed - note it has a nice GUI Benchmark available under Tools / Benchmark"
  loggit "+ (that unfortunately cannot be called from the command line)"
  loggit "+ or there is a beta Linux benchmark test available at: https://www.pickysysadmin.ca/2016/09/03/veracrypt-cli-benchmark-script/"
fi

loggit "o PREP - Copy ~1GB iso file to ramdisk if not already there" 
[ -e /Volumes/ramdisk ] && [ -e "$isofile" ] && time cp -vn "$isofile" /Volumes/ramdisk |tee -a $logfile
rc=$?
[ "$rc" -gt 0 ] && failexit 404 "$isofile failed to copy to ramdisk"

# get current zfs supported encryption types (NOTE depends on up-to-date man page) - output commasep
# yes, this is 3 different replace methods ;-) who doesn't like to show off a bit now and then

#encrline=$(man zfs|grep "encryption=" |head -n 1 |sed 's/|/,/g' |sed 's/off,on,//g')
# fails on osx

# read zfs man page, get ciphers, change pipe to comma, blank out unnec. stuff
# OSX workaround: (from ' man man ' )
encrline=$(man zfs |col -b |grep 'encryption=' |head -n 1 |sed 's/|/,/g') #|sed 's/on,off,//g') 
# NOTE on/off is REVERSED from linux(!) so we process differently below in case they change it to match
#     encryption=on,off,aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm
encrline=$(echo "$encrline" |tr -d '[:space:]') # strip blanks
encrline=${encrline/on,/}    # bash inline sed, replace string with blank
encrline=${encrline/off,/}    
encrline=${encrline/encryption=/}

loggit "o Supported ZFS encryption types (per ' man zfs ')"
loggit "$encrline"
# we expect something like:
#aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm

# REF: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash#tab-top
# read string into bash array - rather elegant
oIFS="$IFS"
IFS=","
declare -a encrtype=($encrline)
IFS="$oIFS"
unset oIFS

#generate 32 byte passkey ONLY if not already exist
#[ -e $zfskeyloc ] || dd if=/dev/urandom of="$zfskeyloc" bs=1 count=32
[ -e $zfskeyloc ] || dd if=/dev/urandom of="$zfskeyloc" bs=32 count=1

# NOTE omit xattr=sa for freebsd as of 2020.0526, may change after support is added to their code
# NOTE relatime and acltype=posixacl are missing from OSX zfs port as of 2020.0526
for testencr in "${encrtype[@]}"; do
  loggit "o Creating $zp dataset for $testencr (if it doesnt already exist)"
  
  [ -e /Volumes/$zp/Test-$testencr ] || \
  zfs create -o \
    atime=off -o compression=$compr -o sharesmb=off -o recordsize=1024k \
    -o encryption=$testencr \
    -o keyformat=raw \
    -o keylocation=file://"$zfskeyloc" \
    -o normalization=formD \
    -o xattr=sa \
    $zp/Test-$testencr || failexit 99 "! Failed to create ZFS $zp/$testencr"

    loggit "$(zfs get encryption,keylocation $zp/Test-$testencr)"
done
    
#sync # may not want to do this if you have a long e.g.  backup process running
# osx rough equiv = 'purge'

#free
#echo 1 > /proc/sys/vm/drop_caches # free pagecache
#free

gdf -hT |head -n 1
gdf -hT |egrep "$zp|ramdisk"
ls -lh /Volumes/ramdisk/*.iso

loggit "$(date) $0 - $(hostname)"
loggit "+ Ready for testing" # from here you can test how long it takes to copy iso file, run fio, etc
# time (cp -v $isofile /$zp/aesdataset; sync) - linux
# time cp -v $isofile /Volumes/$zp/aesdataset # NOTE osx nicely waits for the sync to finish

echo "o $0 Logfile is: $logfile"

exit;


#################################################

2021.0129 minor code cleanup, chg to ~4GB RAMdisk & ISO

2020.0526 Author: Kneutron - knocked together a zfs test script to create datasets per encryption type

2020.0526 Mod for OSX
2020.0527 V2 - minor changes, more descriptive, major functionality still the same

Known bug: logfile does not capture initial openssl tests:
#Doing aes-128 cbc for 3s on 16 size blocks: 14957278 aes-128 cbc's in 2.87s

OSX HOWTO create file-based pool: 
[[
zp=zfilepool; time truncate -s 8000MiB zfile1 && \
zpool create -o ashift=12 -o autoexpand=off -o autoreplace=off -O compression=lz4 -O atime=off $zp $PWD/zfile1
#   pool: zfilepool
# state: ONLINE
#  scan: none requested
#config:
#        NAME                       STATE     READ WRITE CKSUM
#        zfilepool                  ONLINE       0     0     0
#          /var/root/tmpdel/zfile1  ONLINE       0     0     0
#errors: No known data errors

]]

TODO benchmarks: https://malcont.net/2017/07/apfs-and-hfsplus-benchmarks-on-2017-macbook-pro-with-macos-high-sierra/

#SKIP filevault2 commands: https://macadmins.psu.edu/files/2012/11/psumacconf2012-filevault.pdf


NOTE if reboot or $thing happens to zpool such as export,  you may need to:

 zfs load-key $zp/encrtype
 zfs mount -a

NOTE if doing this on an ssd-based pool, you may want to "zpool trim $zp" after doing cleanup


# note this does not work on osx (fixed on osx port) - REF: https://stackoverflow.com/questions/41489692/how-to-search-linux-man-pages-e-g-with-grep
$ man zfs|grep "encryption=" |head -n 1 |sed 's/|/,/g' |sed 's/off,on,//g'
     encryption=off|on|aes-128-ccm|aes-192-ccm|aes-256-ccm|aes-128-gcm|aes-192-gcm|aes-256-gcm
     
     encryption=off,on,aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm
     
     encryption=aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm

/zmsata480 # for z in `echo aes*`; do echo $z; zfs destroy zmsata480/$z;done

