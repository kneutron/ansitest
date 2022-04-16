#!/bin/bash5

# osx, should adapt easily to linux
# REF: http://girlyngeek.blogspot.com/2014/02/zfs-on-read-only-devices.html
# Having trouble importing zpool on osx from "raw" write w/no containing filesystem, 
#   decided to switch to UDF filesystem for optical - mount that and import zfs file-based pool

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

userowns=dave # xxx TODO EDITME

# xxx EDITME
zpfile=zopticalpool
fsize=4400 # MB - for standard DVD+/-R
howmany=1 # for 4.7G DVD+RW

function mkpool () {
  echo "o $PWD - Creating optical zpool of $howmany""x$fsize"" MB"
  for z in $(seq 1 $howmany); do
    time gdd if=/dev/zero of="$zpfile"_$z bs=1M conv=sparse count=$fsize \
    || failexit 99 "Failed to DD output zpool file $z"
  done
}

# Only if not exist
[ -e "$zpfile"_1 ] || mkpool

chown -v $userowns $zpfile*

# xxx EDITME
zp=myzfsdvd
devs=$(echo $PWD/zopticalpool_*)
# -O mountpoint=$HOME/myzfsdvd -O checksum=sha256 \
# NOTE RAID0
zpool create -o ashift=11 -o failmode=continue -o autoexpand=off -o autoreplace=off \
 -O checksum=sha256 -O compression=gzip-9 -O dedup=on \
 -O atime=off -O devices=off -O exec=off -O setuid=off \
 $zp $devs \
 || failexit 101 "Failed to create zpool $zp"

mp=$(zfs get mountpoint $zp |tail -n 1 |awk '{print $3}')
#NAME      PROPERTY    VALUE              SOURCE
#myzfsdvd  mountpoint  /Volumes/myzfsdvd  default
#/Volumes/myzfsdvd

# osx
[ $(df |grep -c Volumes/$zp) -gt 0 ] && chown -v $userowns /Volumes/$zp
# Linux
[ -e /$zp ] && chown -v $userowns /$zp

zpool status -v $zp |awk 'NF>0'
ls -al $mp
echo ''
gdf -hT |head -n 1
gdf -hT |grep $zp

echo '====='
echo "To burn to disc, FIRST zpool export $zp"
echo "To re-import $zp -- mount dvd, cd to it, then zpool import -o readonly=on $zp -d \$PWD"

echo "/Volumes/zfsoptical # zpool import -a -o readonly=on -d \$PWD" > howto-reimport-zpool.txt
cp -v $0 $PWD

exit;


# OSX disc burning REF: https://support.apple.com/guide/mac-help/burn-cds-and-dvds-mchl8addfd95/12.0/mac/12.0
# to burn dvd on osx from files, better to use "burn" app as it can also Erase RW discs

# For larger media, e.g. 50GB Bluray, might want to do copies=2 and forgo raidz1 as seeking will slow down I/O

declare -A ASsector # assoc array

ASsector[74min]=333000          # for 74-min CD-Rs and CD-RWs / 650MB
ASsector[80min]=360000          # for 80-min CD-Rs and CD-RWs / 700MB
ASsector[dvd]=2298496           # for single-layer DVD-Rs
ASsector[dvddouble]=4171712     # for double-layer DVD-Rs
ASsector[dvdplusr]=2295104      # for single-layer DVD+Rs
ASsector[dvdplusr2]=4173824     # for double-layer DVD+Rs
ASsector[bluray]=12219392       # for single-layer Blu-rays
ASsector[bluray2]=24438784      # for double-layer Blu-rays
ASsector[bluray3]=48878592      # for triple-layer Blu-rays
ASsector[bluray4]=62500864      # for quad-layer Blu-rays

usesector=${ASsector[dvdplusr]} 
#echo $usesector
