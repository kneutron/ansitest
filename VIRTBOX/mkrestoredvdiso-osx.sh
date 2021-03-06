#!/bin/bash

# mod for osx 2019.0818
# make a restore DVD from .fsarchive + restore script(s)
# NOTE this does not need to be run as root
# NOTE mkisofs is BROKEN on osx (macports and brew)
# REF: https://www.makeuseof.com/tag/how-to-create-windows-compatible-iso-disc-images-in-mac-os-x/
# REF: http://osxdaily.com/2012/03/16/create-iso-images-from-the-command-line/

# this is where the .fsarchive backup + restore scripts live, pass as arg
d2b="$1"
cd "$d2b"

ls -alh
pwd

echo "$(date) - Writing UDF ISO from $d2b to $HOME - PK:"
#read

hdiutil makehybrid -verbose -iso -joliet -udf -print-size "$d2b"
echo "Sawright?"
#read -n 1

time hdiutil makehybrid -verbose -iso -joliet -udf -o $HOME/restoreUDF.iso "$d2b"
chmod a+rx $HOME/restoreUDF.iso

ls -lh $HOME/restoreUDF.iso

exit;


#mkisofs -r -f -U -v -o - * \

isopts="-iso-level 3 -J -joliet-long -r -T -v "
#isopts="-iso-level 3 -T -v "

# how big willit be
mkisofs $isopts -udf -print-size *
echo Sawright?
read -n 1

time \
  mkisofs -iso-level 3 -allow-lowercase -d -D -f -J -joliet-long -max-iso9660-filenames -N -r -T -udf -v \
  -o $HOME/restoreUDF.iso *

chown dave /home/restoreUDF.iso
chmod a+rx /home/restoreUDF.iso

ls -lh $HOME/*.iso
