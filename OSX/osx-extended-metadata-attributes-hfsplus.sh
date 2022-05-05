#!/bin/bash

# REF: https://apple.stackexchange.com/questions/85699/any-risks-in-creating-custom-os-x-extended-attributes
# store *sum information along with the file for future backup/comparison

if [ "$1" = "" ]; then
  outf=metadata-test
  cd /tmp
else
  outf="$1"
fi

[ "$outf" = "metadata-test" ] && echo "thys be randome texte" >$outf
#ls -alh $outf

# see ' man xattr '
# copy the md5sum for the file to its own metadata
xattr -w md5 $(md5sum $outf |awk '{print $1}') $outf

#79a6a33cf17bf7550486c58836928193  metadata-test
# ^ md5sum output

#xattr -l $outf
#md5: 79a6a33cf17bf7550486c58836928193

xattr -w sha1 $(sha1sum $outf |awk '{print $1}') $outf

set -x
xattr -l $outf
ls -lh@ $outf

