#!/bin/bash

# (2022) Dave Bechtel - example of HOWTO properly expand a raidz / raidz2 with another vdev (increase free space)
# Disks should be of equal size

# REF: https://docs.oracle.com/cd/E19253-01/819-5461/gazgw/index.html

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

echo "$(date) - Creating files for temporary zpool"

# if truncate not installed, use dd
if [ $(which truncate |wc -l) -gt 0 ]; then
# if not exist in curdir, create sparse files
  [ -e zfile1 ] || time truncate -s 500M zfile{1..12}
# NOTE this works fine on ext4, if your filesystem (OSX) does not support truncate it will require ~6GB of diskspace
# You can probably reduce the filesize to 256MB if needed
else
  echo "Using dd"
  [ -e zfile1 ] || for i in {1..12}; do
    time dd if=/dev/zero of=zfile$i bs=1M count=256
  done
fi

# Labelclear is necessary sometimes if files/disks have previously been in a zpool and are being reused
function clearit () {
  echo "Labelclearing"
  for i in {1..12}; do
    zpool labelclear zfile$i
  done
}

[ "$1" = "clear" ] && clearit

zp=ztestpoolraidz1
echo "$(date) - Creating raidz1 pool $zp"
zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
  raidz $PWD/zfile1 $PWD/zfile2 $PWD/zfile3

# Obv. if you were scripting this for disks, you would use /dev/sdb or whatever applies
# You can Create the pool with whatever devs are convenient,
# but you should export and re-import with " -d /dev/disk/by-id " or whatever long format is suitable for you

function zps () {
# skip blank lines  
  zpool status -v $zp |awk 'NF>0'
}

zps
read -p "Press enter to expand raidz pool or ^C"

(set -x
zpool add -o ashift=12 $zp raidz $PWD/zfile4 $PWD/zfile5 $PWD/zfile6
)

zps
read -p "Press enter to destroy $zp and reconfigure as raidz2, or ^C"

zpool destroy $zp || failexit 99 "Failed to destroy $zp, cannot continue"

zp=ztestpoolraidz2
zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
  raidz2 $PWD/zfile1 $PWD/zfile2 $PWD/zfile3 $PWD/zfile4 $PWD/zfile5 $PWD/zfile6 \
 || failexit 101 "Failed to create raidz2 $zp, cannot continue"

zps
read -p "Press enter to expand raidz2 pool with another vdev or ^C"

(set -x
zpool add -o ashift=12  $zp raidz2 $PWD/zfile7 $PWD/zfile8 $PWD/zfile9 $PWD/zfile10 $PWD/zfile11 $PWD/zfile12
)

zps
read -p "Thus endeth the lesson. Press enter to destroy $zp, or ^C"

zpool destroy $zp || failexit 199 "Failed to destroy $zp, please destroy manually"
echo "$zp Destroyed. Please delete zfile* manually,"

exit;

Troubleshooting:
If necessary run ' zpool labelclear ' against the files or delete zfile1 to recreate the files
^^ Pass "clear" to this script as parameter

By default, this script does NOT delete the zfiles when done. Consider it a safety feature.

/home # truncate -s 500M zfile{1..6}
total 885468
drwxr-xr-x  5 root  root       4096 Feb 21 01:18 .
drwxr-xr-x 22 root  root       4096 Dec 21  2020 ..
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile1
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile2
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile3
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile4
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile5
-rw-r--r--  1 root  root  524288000 Feb 21 01:18 zfile6

  pool: ztestpoolraidz1
 state: ONLINE
  scan: none requested
config:
        NAME              STATE     READ WRITE CKSUM
        ztestpoolraidz1   ONLINE       0     0     0
          raidz1-0        ONLINE       0     0     0
            /home/zfile1  ONLINE       0     0     0
            /home/zfile2  ONLINE       0     0     0
            /home/zfile3  ONLINE       0     0     0
          raidz1-1        ONLINE       0     0     0
            /home/zfile4  ONLINE       0     0     0
            /home/zfile5  ONLINE       0     0     0
            /home/zfile6  ONLINE       0     0     0
errors: No known data errors

  pool: ztestpoolraidz2
 state: ONLINE
  scan: none requested
config:
        NAME               STATE     READ WRITE CKSUM
        ztestpoolraidz2    ONLINE       0     0     0
          raidz2-0         ONLINE       0     0     0
            /home/zfile1   ONLINE       0     0     0
            /home/zfile2   ONLINE       0     0     0
            /home/zfile3   ONLINE       0     0     0
            /home/zfile4   ONLINE       0     0     0
            /home/zfile5   ONLINE       0     0     0
            /home/zfile6   ONLINE       0     0     0
          raidz2-1         ONLINE       0     0     0
            /home/zfile7   ONLINE       0     0     0
            /home/zfile8   ONLINE       0     0     0
            /home/zfile9   ONLINE       0     0     0
            /home/zfile10  ONLINE       0     0     0
            /home/zfile11  ONLINE       0     0     0
            /home/zfile12  ONLINE       0     0     0
errors: No known data errors

If you cannot destroy the zpool, make sure a shell does not have it held open somewhere with " lsof |grep ztestpool "
Any process holding the pool open ( cd /ztestpoolraidzX # is sufficient ) needs to CD out of it or be killed

NOTE: What you DONT WANT is "hanging drives" that are not part of the raidz - if your pool looks like this,
somebody f**ked it up:

  pool: ztestpoolraidz1
 state: ONLINE
  scan: none requested
config:
        NAME              STATE     READ WRITE CKSUM
        ztestpoolraidz1   ONLINE       0     0     0
          raidz1-0        ONLINE       0     0     0
            /home/zfile1  ONLINE       0     0     0
            /home/zfile2  ONLINE       0     0     0
            /home/zfile3  ONLINE       0     0     0
          raidz1-1        ONLINE       0     0     0
            /home/zfile4  ONLINE       0     0     0
            /home/zfile5  ONLINE       0     0     0
            /home/zfile6  ONLINE       0     0     0
          /home/zfile7    ONLINE       0     0     0
errors: No known data errors

NOTE you really have to work at it to mess this up by FORCING zfs to improperly add the dev:

# zpool add ztestpoolraidz1 $PWD/zfile7
invalid vdev specification
use '-f' to override the following errors:
mismatched replication level: pool uses raidz and new vdev is file

If your pool vdevs are not properly balanced, you will need to backitup, destroy / recreate it with proper
  balanced vdevs, and Restore - if you leave it unbalanced and the wrong drive fails, the whole pool can fail!
