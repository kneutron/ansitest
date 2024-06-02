#!/bin/bash

# DEPENDS: smartctl, parted, fdisk

echo "Parameter: Supply short device name [sdb], etc"
echo "MAKE SURE you supply the right disk device - author takes NO RESPONSIBILITY for data loss!"
echo "Use at your own risk!"
argg=$1

[ $(which parted |wc -l) -gt 0 ] || apt-get install -y parted

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}


smartctl -a /dev/$argg |head -n 16
fdisk -l /dev/$argg

ls -l /dev/disk/by-id |grep $argg

echo "THIS WILL DESTRUCTIVELY APPLY A GPT LABEL to /dev/$argg - ARE YOU SURE - Enter to proceed OR ^C"
read

parted -s /dev/$argg mklabel gpt || failexit 99 "! Failed to apply GPT label to /dev/$argg"

fdisk -l /dev/$argg

exit;
