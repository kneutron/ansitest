#!/bin/bash

# Linux version 
# make a restore DVD from .fsarchive + restore script(s)

# Destination dir
d2b="$1"
cd "$d2b"

ls -alh
pwd

echo "Creating ISO from $d2b..." #PK:
#read

#mkisofs -r -f -U -v -o - * \

# how big willit be
mkisofs -d -D -f -l -J -N -r -T -v -print-size *
echo Sawright?
#read

time \
  mkisofs -allow-lowercase -apple -d -D -f -l -J -joliet-long -max-iso9660-filenames -N -r -R -T -udf -v \
  -o /home/restoreUDF.iso *
#  | cdrecord -v -tao fs=5120k -eject speed=32 -data -
#  | cdrecord -v -tao fs=5120k -eject speed=$CDR_SPEED -data -

#dev=1,0,0
chown dave /home/restoreUDF.iso
chmod a+rx /home/restoreUDF.iso

ls -lh /home/*.iso

exit;

# 2021 Dave Bechtel
