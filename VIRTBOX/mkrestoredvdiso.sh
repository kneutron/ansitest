#!/bin/bash

# Linux version 
# make a restore DVD from .fsarchive bare-metal backup + restore script(s): RESTORE-fsarchive-root.sh // and/or to-XFS version
# mount the resulting ISO in a systemrescuecd environment on 2nd dvd drive

# xxx TODO editme
user=dave
outfile=/home/$user/restoreUDF.iso

# This is where the fsarchive backup and restore script lives, pass as parm
d2b="$1"
cd "$d2b"

ls -alh
pwd

echo "Creating UDF ISO from $d2b ..." #PK:
#read

# how big willit be
mkisofs -d -D -f -l -J -N -r -T -v -print-size *
echo Sawright?
#read

time \
  mkisofs -allow-lowercase -apple -d -D -f -l -J -joliet-long -max-iso9660-filenames -N -r -R -T -udf -v \
  -o $outfile *

chown $user $outfile
chmod a+rx $outfile

ls -lh /home/$user/*.iso

exit;

# 2021 Dave Bechtel
