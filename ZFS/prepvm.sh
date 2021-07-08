#!/bin/bash

# NOTE VM MUST NOT BE RUNNING
ls -alh
vbm="VBoxManage" # Virtualbox
# Shrinkydink
#time $vbm modifymedium --compact test-zfs-21-Draid-sata0-0-roothomeswap.vdi
time $vbm modifymedium --compact test-zfs-21-Draid-sata0-0.vdi
ls -alh

# Cleanup
/bin/rm -f Logs/*
/bin/mv *~ ~/tmpdel

# use 7zip instead

dirtobkp="test-zfs-21-Draid--xfs"
outfile="$dirtobkp"'.7z'

cd ..
/bin/rm -f $outfile

time 7z \
 a \
 -mx=9 \
 -ms=on \
 $outfile \
 $dirtobkp
   
time md5sum -b $outfile > $dirtobkp.md5
time sha1sum -b $outfile > $dirtobkp.sha1
cat *.md5 *.sha1
ls -alh

date;
exit;

time rar \
 a \
 -m5 \
 -md4096 \
 -rr1p \
 -ol \
 -ow \
 -o+ \
 -r \
 -tsm \
 -tsc \
 -s \
 -- \
 $outfile \
 $dirtobkp
