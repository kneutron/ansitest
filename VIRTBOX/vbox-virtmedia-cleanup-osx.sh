#!/bin/bash5

# 2021 Dave Bechtel
# mod for osx
# REQUIRES: egrep, grep, wc, vboxmanage

infilehd=/tmp/infile-vboxdel-hdd.txt
> $infilehd # clearit
infiledvd=/tmp/infile-vboxdel-dvd.txt
> $infiledvd # clearit
logfile=/tmp/vbox-hd-inacc-del.log
mv $logfile $logfile-old

# cleanup inaccessible disks in VMM
vboxmanage list hdds |egrep 'UUID|State|Location|Capacity' > /tmp/vbox-media-all.txt
vboxmanage list dvds |egrep 'UUID|State|Location|Capacity' >> /tmp/vbox-media-all.txt

vboxmanage list hdds |grep -B 2 'State:          inaccessible' \
  |egrep -v 'Parent|State|--' >$infilehd
vboxmanage list dvds |grep -B 2 'State:          inaccessible' \
  |egrep -v 'Parent|State|--' >$infiledvd
#zfs-SAS-T5-12*.vdi > /tmp/infile.txt

ls -al $infilehd $infiledvd
wc -l $infilehd
echo '^^ HD + DVD vv '
wc -l $infiledvd
echo '^ Total to delete -- PK to delete inaccessible media or ^C to abort'
read -n 1

set -x
while read line; do
  delme=$(echo "$line" |awk '{print $2}')
  [ "$delme" = "" ] && continue;

  echo "$delme" >> /tmp/vbox-hd-inacc-del.log
   
  vboxmanage closemedium disk "$delme" --delete
done < $infilehd

while read line; do
  delme=$(echo "$line" |awk '{print $2}')
  [ "$delme" = "" ] && continue;

  echo "$delme" >> /tmp/vbox-hd-inacc-del.log
   
  vboxmanage closemedium dvd "$delme" --delete
done < $infiledvd

date;

exit;

# hdd
UUID:           a35521e9-4e99-46b5-bdfd-7611a69986f2
Parent UUID:    base
State:          created
Type:           normal (base)
Location:       /Volumes/zsam53/virtbox-gz2/win10-p2v-testrestore-dellap/win10-p2v-testrestore-dellap.vdi
Storage format: VDI
Capacity:       61440 MBytes
Encryption:     disabled

UUID:           54c1a200-707a-4082-866d-dde2d53d0b22
Parent UUID:    base
State:          inaccessible
Type:           normal (base)
Location:       /Volumes/zsgtera4/shrcompr-zsgt2B/dv/ultimate-edition--32-browse.vmdk
Storage format: VMDK
Capacity:       0 MBytes
Encryption:     disabled

# dvd
UUID:           661663aa-f9d4-438f-b365-e687e1c21dc9
State:          created
Type:           readonly
Location:       /Volumes/zsgtera4/shrcompr-zsgt2B/ISO/FreeNAS-11.2-U7.iso
Storage format: RAW
Capacity:       574 MBytes
Encryption:     disabled

UUID:           35b76e02-8d16-4a1b-970b-d576e4685d5c
State:          inaccessible
Type:           readonly
Location:       /Volumes/zsgtera4/shrcompr-zsgt2B/ISO/MX-19.2_x64.iso
Storage format: RAW
Capacity:       0 MBytes
Encryption:     disabled
