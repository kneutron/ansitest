#!/bin/bash

# DEPENDS: fdisk, parted, pstree, fuser, working zfs install
# Strongly recommended to run from GNU SCREEN 
# Also you need to be on tty1 (or similar) logged in directly as root, NOT SUDO and preferably not ssh
# NOTE this script is interactive and will wait for multiple PK = press a key/enter to proceed

# DONE? - sep datasets for users

# DONE new disk needs to be at least = size of /home du -s -h
# DONE free snapshot

# GOAL: move existing /home to zfs
# $1 = disk name (long or short) OR existing zfs poolname

# 2016 Dave Bechtel

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Check for root priviliges
if [ "$(id -u)" -ne 0 ]; then
   failexit 1000 "Please run $0 directly as root from tty1. X window manager cannot be running"
   exit 1
fi

# TODO chk tty - if pts, logout and goto tty1
# REF: https://www.cyberciti.biz/faq/linux-unix-appleosx-bsd-what-tty-command/
#whereameye=$(tty)
#if [ $(echo $whereameye |grep -c pts) -gt 0 ]; then
#  failexit 7 "Please log off, press Ctrl+Alt+F1 or if using Virtualbox right-Ctrl+F1 / OSX use right-CMD+F1 and login directly as root to run this"
# NOTE root must have a password  
#fi
# ^ problematic - 'screen' on tty1 also has a pty

# xxx TODO EDITME set compression type for new datasets - 2.0.x supports zstd
compr=lz4
#compr=zstd-2

logfile=~/boojum-mvhome2zfs.log
#source ~/bin/logecho.mrg
#logecho.mrg 
# Echo something to current console AND log
# Can also handle piped input ( cmd |logecho )
# Warning: Has trouble echoing '*' even when quoted.
function logecho () {
  args=$@

  if [ -z "$args" ]; then
    args='placeholder'

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

# blankit
> $logfile

# If set to 1, will interactively kill user processes
# EITHER of these options (if set) will destroy existing ZFS datasets!
debugg=0
RESETALL=0
# DANGEROUS - ONLY SET IF U KNOW WHAT U DOING AFTER RESTORING A SNAPSHOT!
# WILL DESTROY $zp

# xxx TODO EDITME  to be the name of the ZFS home pool you want to be created, if needed
zp=zhome
[ $RESETALL -gt 0 ] && (set -x; zpool destroy $zp)

tmpfile1=/tmp/mvh2zTMP1.txt

modprobe zfs  # shouldnt hurt even if its already loaded

# is zfs installed?
#zfsps=`zpool status |head -n 1`
zfsps=$(zfs list |head -n 1)

if [ $(echo "$zfsps" |grep -c 'MOUNTPOINT') -ge 1 ]; then
  logecho 'Existing zfs pool(s) detected:'
  zpool status |awk 'NF>0'
  echo 'FYI: Pass a ZFS pool name to this script to move /home there, or pass a disk name to create a new pool'
elif [ $(echo "$zfsps" |grep -c 'no datasets available') ]; then
  logecho "NOTE: ZFS is installed and appears to be working - will create a pool ( $zp ) to hold /home"
else
  logecho '! ZFS does not appear to be installed or is not working correctly'
  failexit 99 '! zpool status is not returning a valid result:'
  (set -x
   zpool status )
fi

# TODO fix/re-enable
#[ `mount |grep /home |grep -c 'type zfs'` -ge 1 ] && failexit 109 "! Home already appears to be ON zfs!"
# bigvaiterazfsNB/home on /home type zfs (rw,noatime,xattr,noacl)

# Is /home a dir hanging off root or sep partn?
#sephome=`df /home |grep /home |awk '{ print $1 }'`
hmnt=$(mount |grep /home |awk '{ print $1 }' |head -n 1) # 1st line only
# bigvaiterazfsNB/home OR /dev/sdX9

roothome=0
homespc=0
if [ $(echo $hmnt |grep -c '/dev') -gt 0 ]; then
  echo '';logecho "o Your /home appears to be on $hmnt"
  df -hT /home
elif [ -d /home ]; then
  logecho "o Your /home does not appear to be on a separate partition, is a directory on the root filesystem"
  echo "...Please wait while I determine how much space it is using..."
  homespc=$(du -s -k /home |awk '{print $1}') # 431484266       /home
  logecho $homespc
  roothome=1
else
  failexit 201 "! This fallthru should not happen, cannot determine /home!"
fi

# skip header line and grab 3rd field (Used)
#[ $debugg -gt 0 ] && homespc=16011904 # 16GB  # TODO testing - only set this if there is nothing in /home
[ $homespc = 0 ] && homespc=$(df -k /home |tail -n +2 |awk '{ print $3 }')

let hsbytes=$homespc*1024

# REF: https://unix.stackexchange.com/questions/222121/how-to-remove-a-column-or-multiple-columns-from-file-using-shell-command
# get a list of long drive names with short; strip out blank lines and unnec fields
/bin/ls -go /dev/disk/by-id /dev/disk/by-path \
  |egrep -v 'part|wwn|total |dev/' \
  |awk 'NF>0' \
  |awk '{$1=$2=$3=$4=$5=$6=""; print $0}' \
  |column -t \
  > $tmpfile1

echo '';echo "o These are the hard drives found on your system:"
# NOT an unnec use of cat - REF: https://unix.stackexchange.com/questions/16279/should-i-care-about-unnecessary-cats
cat $tmpfile1
echo ''

# did we get passed a disk or existing ZFS pool?
argg=$1
[ "$argg" = "" ] && failexit 199 "! Cannot proceed - pass at least a disk device name (long or short form) OR zfs pool to move /home to!"

usepool=""; usedisk=""
if [ $(grep -c $argg $tmpfile1) -gt 0 ]; then
  logecho "o You apparently want me to use this disk:"
  bothforms=$(grep $argg $tmpfile1)
  echo "$bothforms"

  getlongdisk=$(grep $argg $tmpfile1 |awk '{ print $1 }' |head -n 1)
  shortdisk=${bothforms##*/} # strip off all leading "/"
  shortdev=/dev/$shortdisk
  usedisk=$getlongdisk

  echo ''; logecho "o Using long-form diskname: $usedisk - Short form: $shortdev"
  echo "^^ If this is incorrect, then rerun this script and use a more specific device name!"

# test for cd = add all results (tmpusingcd)
  ttlusecd=0 # TOTAL

#TMPusecd
  tucd=$(echo $argg |egrep -c 'sr0|sr1|scd0|scd1|cdrom|cdrw|dvdrw')
  let ttlusecd=$ttlusecd+$tucd

  tucd=$(echo $shortdisk |egrep -c 'sr0|sr1|scd0|scd1|cdrom|cdrw|dvdrw')
  let ttlusecd=$ttlusecd+$tucd

#  [ `echo $argg |grep -c sr1` -gt 0 ] && failexit 401 "! I cant use a CDROM device, wiseguy!!"
  [ $ttlusecd -gt 0 ] && failexit 5150 "! I cant put /home on a CDROM device, wiseguy!! Try again with a hard drive!"


# test for existing filesystem on destination disk - especially if sda!
  echo "...Checking blkid and zpools to see if the disk you specified is OK to use..."

  [ $(echo $hmnt |grep -c $shortdev) -gt 0 ] && failexit 502 "! You CRAZY MANIAC - you cant re-use your existing home disk in-place for ZFS!!"

  alreadyf=$(blkid |grep -c $argg)
  alreadyf2=$(blkid |grep -c $shortdev)
  let alreadyf=$alreadyf+$alreadyf2
#/dev/sde1: LABEL="zredpool2" UUID="17065421584496359800" UUID_SUB="1595728817173195411" TYPE="zfs_member" PARTLABEL="zfs"
#/dev/sda2: LABEL="xubuntu1404" UUID="103f019e-1275-4c27-a972-5b5d3874b863" TYPE="ext4" PARTUUID="b680669e-02"

# ISSUE - blkid is not always up to date, not detecting newly created test pools!
  alreadyf2=$(zpool status |grep -c $usedisk)
  let alreadyf=$alreadyf+$alreadyf2
  alreadyf2=$(zpool status |grep -c $shortdisk)
  let alreadyf=$alreadyf+$alreadyf2
  alreadyf2=$(zpool status |grep -c $argg)
  let alreadyf=$alreadyf+$alreadyf2
    

# NOTE empty GPT label will not show on blkid!
  [ $alreadyf -gt 0 ] && failexit 302 "! Disk is already formatted/IN USE and needs to either be blank or have an empty GPT label: $shortdev / $usedisk"

# Check disk capacity against existing
# fdisk -l /dev/sdb |grep Disk |grep -v 'identifier'
# 1   2         3    4   5
#Disk /dev/sdb: 1000 GB, 1000202273280 bytes
  dcap=$(fdisk -l $shortdev |grep Disk |grep -v 'identifier' |awk '{print $5}')
[ $debugg -gt 0 ] && logecho "dcap: $dcap ^^ homespc: $hsbytes"

# comma-sep nums - REF: https://unix.stackexchange.com/questions/113795/add-thousands-separator-in-a-number
if [ $dcap -lt $hsbytes ]; then
  dcapcma=$(printf "%'d" $dcap)
  hsbcma=$(printf "%'d" $hsbytes)

  logecho "! Disk capacity of $usedisk is less than home data usage!"
  logecho "Home: $hsbcma"
  logecho "Disk: $dcapcma"
  failexit 999 "! Selected Disk capacity of $usedisk is less than home data usage - choose a larger disk or use a larger zpool!"
fi

################################# POINT OF NO RETURN - POSSIBLE DATA DESTRUCTION AFTER THIS!
  fdisk -l $shortdev |tee -a $logfile 2>>$logfile
  echo '';logecho "YOU ARE ABOUT TO DESTRUCTIVELY GPT LABEL DISK: $usedisk"
  echo "ENTER ADMIN PASSWORD TO PROCEED OR ^C: "
  read

  ( set -x
   zpool labelclear $shortdev
   parted -s $shortdev mklabel gpt
   fdisk -l $shortdev |tee -a $logfile)
    
elif [ $(zfs list -d0 |grep -c $argg) -gt 0 ]; then
  logecho "o You apparently want me to use this pre-existing ZFS pool for /home:"
  zfs list -d0 |grep $argg |head -n 1
  usepool=$argg
  zp=$argg # using pre-existing pool
else
  failexit 404 "! Cannot proceed - $argg was not found on the system!"
fi # did we get passed a disk or existing ZFS pool?


# create the pool if needed
if [ "$usedisk" != "" ] && [ "$usepool" = "" ]; then
    [ "$zp" = "" ] && zp=zhome
# set a default name
(set -x
    zpool create -o ashift=12 -o autoexpand=on -o autoreplace=on \
     -O atime=off -O compression=$compr \
    $zp \
    $usedisk
    
    zpool status |awk 'NF>0'
)
fi

# from now on, we are using pool!
(set -x
[ $debugg -gt 0 ] && zfs destroy $zp/home
 zfs create -o sharesmb=off -o compression=$compr $zp/home )

zfs list -p $zp 

# TODO check for zfs pool free space vs home use
  zpcap=$(zfs list -p $zp |awk '{ print $3 }' |tail -n +2) # skip header and get bytes
[ $debugg -gt 0 ] && logecho "zpcap: $zpcap ^^ homespc: $hsbytes"

if [ $zpcap -lt $hsbytes ]; then
  zpcapcma=$(printf "%'d" $zpcap)
  hsbcma=$(printf "%'d" $hsbytes)

  logecho "! Usable ZFS pool capacity of $zp is less than home data usage!"
  logecho "Home: $hsbcma"
  logecho "Pool: $zpcapcma"
  failexit 919 "! Selected ZFS pool $zp is smaller than home data usage - choose a larger disk or use a larger zpool!"
fi


# Permission was already given, but make sure it's OK to logoff all users
logecho "! NOTE: by proceeding from here, you will be shutting down the X window manager (GUI) and LOGGING OFF all non-root users!"
logecho ' /^^ MAKE SURE ALL YOUR DATA IS BACKED UP / SAVED BEFORE PROCEEDING ^^\'
logecho "You need to be DIRECTLY logged into tty1 or similar as the root userid!"
logecho "ENTER ADMIN PASSWORD TO PROCEED, OR ^C - you need to be running this script directly as root without using sudo!"
read

# Determine WM
xwm=$(pstree -psu -A |grep Xorg)
#        |-lightdm(1325)-+-Xorg(1388)
xwmedit=$(echo $xwm |awk -F\( '{ print $1 }')
#|-lightdm
xwmedit2=${xwmedit##*-} # strip off to "-"  ${tmp2##*-}
#lightdm

[ "$xwmedit2" = "" ] || service $xwmedit2 stop
sleep 2

# OK so far, check if anything in /home is locked 
function checkhomelock () {
  flocks=$(lsof |grep -c /home)
}

logecho "$(date) ! Force-logging off anyone who is locking /home files..."
# xxxxx workaround, root getting fragged off
flocks=0
while [ $flocks -gt 0 ]; do
[ $debugg -gt 0 ] && fopts="-i "
#  for myuser in `w -h |grep -v root |awk '{print $1}' |sort |uniq`; do
#    fuser $fopts -u -v $myuser
    fuser $fopts -k -u -v -m /home
#  done
  checkhomelock
  sleep 5;date
done

lsof |grep /home
logecho "o All /home files should be free! If not, ^C and fix it! PK"
read

du -s -h /home
logecho "$(date) - Copying /home data over to /$zp/home"
cd /$zp/home || failexit 405 "! FARK - I cant cd to /$zp/home !"
cd /home; df -hT /home /$zp

# xxx TODO test - create datasets for each user; can still proceed if this step fails
for usrs in $(ls -1 /home |awk '{print $1}'); do
# if they dont exist, cre8 them
  [ -e /$zp/home/$usrs ] || \
   zfs create -o atime=off -o compression=$compr -o sharesmb=off -o recordsize=128k \
     $zp/home/$usrs     # || failexit 999 "! Failed to create ZFS $zp/home/$usrs"
done

ls -al /$zp/home

# had problems with ownership permissions
#time tar cpf - * |pv |(cd /$zp/home; tar xpf - ) || failexit 1000 "! Copying home data failed - check free space!"
# xxxxx 2024.0404 EXPERIMENTAL but appears to work
echo "$(date) + Beginning rsync /home to /$zp/home"

time rsync -r -t -p -o -g -v --delete -l -s \
  --exclude=.thumbnails/* \
  /home/ \
  /$zp/home \
  2>~/rsync-error.log \
|| failexit 1000 "! Copying home data to zfs failed - check free space!"

date

df -hT |grep /home

if [ $debugg -gt 0 ]; then
  logecho "PK to unmount old /home or move it out of the way:"
  read
else
  logecho "Unmounting old /home / moving it out of the way:"
fi

if [ $roothome -gt 0 ]; then
  mv -v /home /home--old 
  ls -l / |grep home
else
  cd
  umount /home
fi

# SKIP edit fstab for noauto - NO, too dangerous to risk 

zfs set mountpoint=/home $zp/home
df -hT

[ "$xwmedit2" = "" ] || service $xwmedit2 start
logecho "$(date) - Finished migrating /home"

zfs snapshot -r $zp@snapshot1
zfs list -r -t snapshot

logecho " -- Dont forget to restart the window manager if needed, and edit /etc/fstab - put /home as noauto!"
logecho "Example: # service lightdm restart"
logecho "EXAMPLE /etc/fstab:"
logecho "LABEL=home  /home  ext4  defaults,noauto,noatime,errors=remount-ro  0 1"

# cleanup
/bin/rm -f $tmpfile1

exit;


REQUIRES:
o Working 'zpool status' and 'zfs list'
o grep, awk, column
o parted, fdisk, blkid
o pstree, lsof, fuser
o tar, pv

lrwxrwxrwx 1  9 Apr 26 13:20 usb-VBOX_HARDDISK-0:0 -> ../../sde
lrwxrwxrwx 1 9 Apr 26 13:20 pci-0000:00:0b.0-usb-0:1:1.0-scsi-0:0:0:0 -> ../../sde
lrwxrwxrwx 1 9 Apr 26 13:20 pci-0000:00:14.0-scsi-0:0:0:0 -> ../../sdb
lrwxrwxrwx 1 9 Apr 26 13:20 pci-0000:00:16.0-sas-0x00060504030201a0-lun-0 -> ../../sdc

# column omits leading spaces :)
$ ls -go /dev/disk/by-id /dev/disk/by-path |egrep -v 'part|wwn|total |dev/' |awk 'NF>0' |awk '{$1=$2=$3=$4=$5=$6=""; print $0}'|column -t
ata-VBOX_CD-ROM_VB2-01700376                   ->  ../../sr0
ata-VBOX_HARDDISK_VB2cf5f3dc-6b93417b          ->  ../../sdg
ata-VBOX_HARDDISK_VB3c729abf-3f210fcb          ->  ../../sdd
ata-VBOX_HARDDISK_VB409c8b16-836d593c          ->  ../../sdf
ata-VBOX_HARDDISK_VBb85ec192-1f9a60c7          ->  ../../sda
usb-VBOX_HARDDISK-0:0                          ->  ../../sde
pci-0000:00:0b.0-usb-0:1:1.0-scsi-0:0:0:0      ->  ../../sde
pci-0000:00:14.0-scsi-0:0:0:0                  ->  ../../sdb
pci-0000:00:16.0-sas-0x00060504030201a0-lun-0  ->  ../../sdc

  alreadyf=`blkid |grep -c $argg`
#/dev/sde1: LABEL="zredpool2" UUID="17065421584496359800" UUID_SUB="1595728817173195411" TYPE="zfs_member" PARTLABEL="zfs" PARTUUID="05762e8f-a4e7-fe42-9b1b-3b2431b1f967"
#/dev/sde9: PARTUUID="9a508052-75aa-3047-a9ef-38d8c2d14649"

#/dev/sda2: LABEL="xubuntu1404" UUID="103f019e-1275-4c27-a972-5b5d3874b863" TYPE="ext4" PARTUUID="b680669e-02"
#/dev/sda3: LABEL="rootantiX-16" UUID="264d2bdc-d4df-4d76-a1dc-3096a5e68bb1" TYPE="ext4" PARTUUID="b680669e-03"
#/dev/sda1: PARTUUID="b680669e-01"

  alreadyf2=`blkid |grep -c $shortdev`
  let alreadyf=$alreadyf+$alreadyf2
#/dev/sde1: LABEL="zredpool2" UUID="17065421584496359800" UUID_SUB="1595728817173195411" TYPE="zfs_member" PARTLABEL="zfs"
#/dev/sda2: LABEL="xubuntu1404" UUID="103f019e-1275-4c27-a972-5b5d3874b863" TYPE="ext4" PARTUUID="b680669e-02"
#/dev/sda1: PARTUUID="b680669e-01"
