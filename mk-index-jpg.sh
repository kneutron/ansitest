#!/bin/bash

# 2022 Dave Bechtel
# Create an index .jpg with thumbnails for images in multiple subdirs, one index jpg per subdir
# REF: https://ostechnix.com/how-to-create-a-montage-from-images-in-linux/

# CD to where you need to be b4 running
# cd $HOME/Pictures $ $0

# REQUIRES: imagemagick , findutils , parallel  

# del existing montage jpg first so we dont do Inception
outfile=0montage.jpg

set -u # abort on uninit var
echo "Precleaning $outfile in this dir tree"
find . -name "$outfile" -print -delete
set +u

if [ "$1" = "" ]; then
  echo "Single tasking"
  time find . -type d -print -exec montage -geometry 192x192\>+1+1 -set label '%f\n%wx%h' {}/\* {}/$outfile \;
else
  echo "Using multi-cpu"
  time find . -type d -print \
    | parallel -I@ --max-args 1 \
      montage -geometry 192x192\>+1+1 -set label '%f\n%wx%h' @/\* @/$outfile
# WARNING be aware that montage can use MULTIPLE GIGS OF RAM  
fi

# ^ Find directories starting in this dir (and processing current directory
# as well), print what it finds to somewhat track progress, run montage on
# the files in that dir (you need to escape the star to avoid bash
# autocomplete) with resulting output file named 0montage.jpg in the found dir. 
# PROTIP Prefacing the filename with 0 should sort it to the top in a file manager

date

exit;

To open all the resulting index files (on OSX):

for f in $(find . -name 0montage\*); do open $f; done
# ^ Adapt to your Linux filemanager or you can use imagemagick ' display '

Use "find * " to only process subdirs, not curdir

REF: https://opensource.com/article/18/5/gnu-parallel

$ find . -name "*jpeg" | parallel -I% --max-args 1 convert % %.png
-I% creates a placeholder, called %, to stand in for whatever find hands over to Parallel.
