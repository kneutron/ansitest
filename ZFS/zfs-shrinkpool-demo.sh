#!/bin/bash5

# NOTE this only works on MIRROR pools, NOT RAIDZ

# REF: https://askubuntu.com/questions/1231355/how-can-i-shrink-a-zfs-volume-on-ubuntu-18-04
# Tested with zfs 1.9.4 on OSX High Sierra 10.13 (approx. == ZFS 0.8.6 on Linux)

#source ~/bin/failexit.mrg
# REF: https://sharats.me/posts/shell-script-best-practices/
function failexit () {
  echo '! Something failed! Code: '"$1 $2" >&2 # code (and optional description)
  exit $1
}

# TODO EDITME xxx
dest=/Volumes/sgtera2
iso2cp=/Volumes/ztoshtera10/shrcompr-ztoshtera10/ISO/systemrescue-9.06-amd64.iso

cd $dest || failexit 44 "Cant cd to $dest"

echo "$(date) - Creating virtual zfs disks"
size2=4096
size1=2048

time truncate -s ${size1}M zd1                               
truncate -s ${size1}M zd2
truncate -s ${size1}M zd3
truncate -s ${size1}M zd4

time truncate -s ${size2}M zd5
truncate -s ${size2}M zd6
truncate -s ${size2}M zd7
time truncate -s ${size2}M zd8

ls -lh zd*
date

[ -e zd1 ] || failexit 45 "Cant find zd disks in $dest"

zp=zshrinky
echo "$(date) - Creating zpool $zp"

zpool create -f -o ashift=12 -O atime=off -O compression=lz4 $zp mirror \
 $PWD/zd5 $PWD/zd6 || failexit 64 "Failed to create $zp"
zpool set autoexpand=on $zp

gdf -hT /Volumes/$zp
echo "$(date) - Copying ISO to $zp"
time cp -v $iso2cp /Volumes/$zp
ls -lh /Volumes/$zp

function zps () {
 zpool status -v $zp |awk 'NF>0'
}

zps
zpool list $zp

echo "Press Enter to shrink - existing pool is ~ ${size2}M - or ^C to stop"
read

echo "$(date) - Adding smaller mirror disks"
zpool add $zp mirror $PWD/zd1 $PWD/zd2
zps

echo "$(date) - Shrinkydink"
time zpool remove $zp mirror-0

date

while :; do
  [ $(zps |grep -c "Evacuation of mirror in progress") -eq 0 ] && break
  zps
  zpool iostat -y -T d -v $zp
  sleep 5
done

echo "- DONE -"
zps 
echo ''
zpool list $zp
echo ''
gdf -hT /Volumes/$zp
date

exit;


# Example output
  pool: zshrinky
 state: ONLINE
  scan: none requested
remove: Removal of vdev 0 copied 744M in 0h0m, completed on Wed Apr 26 00:08:13 2023
    18.2K memory used for removed device mappings
config:
        NAME                      STATE     READ WRITE CKSUM
        zshrinky                  ONLINE       0     0     0
          mirror-1                ONLINE       0     0     0
            /Volumes/sgtera2/zd1  ONLINE       0     0     0
            /Volumes/sgtera2/zd2  ONLINE       0     0     0
errors: No known data errors

NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
zshrinky  1.88G   745M  1.15G        -         -     5%    38%  1.00x  ONLINE  -

Filesystem     Type  Size  Used Avail Use% Mounted on
zshrinky       zfs   1.8G  744M  1.1G  42% /Volumes/zshrinky
