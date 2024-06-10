#!/bin/bash

# Source files in /mnt/cdtemp2/dv
# Dest is /mnt/cdtemp

#cd /mnt/cdtemp2/dv
# Curdir instead

# toolame
for c in *.wav;
do
 echo '.'$c'.'
 time lame \
  --disptime 2 \
  -q 4 \
  --vbr-new \
  -V 3 \
  -B 196 \
  $c tmpfile.mp3

mv -v tmpfile.mp3 $c.mp3
#/mnt/cdtemp/audio/$c.mp3

done
ls -alh
##  --preset BLAH \
