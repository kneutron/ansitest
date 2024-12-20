#!/bin/bash

# umount extra recovery HDs
for u in `df |grep Recovery |awk '{print $1}'`; do
  echo $u
  diskutil unmount $u
done

diskutil unmount /Volumes/*CCCRESTORE
diskutil unmount /Volumes/*cccrestore
diskutil unmount /Volumes/CCCrestore*
diskutil unmount "/Volumes/Install macOS High Sierra"
diskutil unmount "/Volumes/CCCrestore-imac5-old-hs1013"
diskutil unmount "/Volumes/OLDERosxint5001013"

diskutil umount "/Volumes/Untitled"
diskutil umount "/Volumes/Untitled 1"
diskutil umount "/Volumes/Untitled 2"

# internal SSD - macmini
diskutil umount "/Volumes/Macintosh HD"
diskutil umount "/Volumes/Macintosh HD - Data"
diskutil umount "/Volumes/Update"

# other beetle with Monterey
diskutil umount "/Volumes/skhynix-1tb-macmini - Data"
diskutil umount "/Volumes/skhynix-1tb-macmini"

# older install
diskutil umount /Volumes/hynix2-ventura-13-macmini
diskutil umount "/Volumes/hynix2-ventura-13-macmini - Data"
diskutil umount /Volumes/cccbkp-ventura-13-macmini-wd6T

#/dev/disk3s1 apfs   233G   33G  201G  14% /Volumes/Samt7-Monterey - Data
#/dev/disk3s3 apfs   233G   33G  201G  14% /Volumes/Samt7-Monterey
#/dev/disk4s1 apfs   230G   86G  145G  38% /Volumes/cccrestore-samt7-mont

diskutil unmount "/Volumes/Samt7-Monterey - Data"
diskutil unmount "/Volumes/Samt7-Monterey"
diskutil unmount /Volumes/cccrestore-samt7-mont
 
# might as well run this too
gig-ether--speedup--osx.sh 

# and this xxx 2024.1204
/var/root/bin/boojum/zfs-osx-sysctl-fixes.sh

gdf -hT
