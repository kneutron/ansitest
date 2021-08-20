#!/bin/bash

# cleanup inaccessible disks in VMM
vboxmanage list hdds > /tmp/vbox-hds-all.txt

vboxmanage list hdds |grep -B 2 'State:          inaccessible' \
  |egrep -v 'Parent|State|--' >/tmp/infile-vboxdel.txt
#zfs-SAS-T5-12*.vdi > /tmp/infile.txt

#set -x
while read line; do
  delme=$(echo "$line" |awk '{print $2}')
  echo "$delme" >> /tmp/vbox-hd-inacc-del.log
   
  vboxmanage closemedium disk "$delme" --delete
done < /tmp/infile-vboxdel.txt

date;
