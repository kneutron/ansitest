#!/bin/bash

# NOTE this is an old version from original cubietruck!  Mar 26  2014 flist

# Go thru .tar.gz, .tar.bz2 in dir and list them to flist-file
function process () {
  args=$*
  echo $args

# if doing rezip, renice bzip2
renice +1 `pidof bzip2` 2>/dev/null

# Preserve existing output
  if [ -e "flist--$bn.txt" ]; then                                                                       
    echo '* Skipped '$bn
  else                                                                                                    
    time $compr -cd $args |tar tvf - > flist--$bn.txt
  fi
}
#function processbz2 () {
#  args=$*
#  echo $args
#  time tar tjvf $args > flist--$bn
#}

# If compare string not match any actual filename, move on
for i in *.tar.gz; do 
  [ "$i" == "*.tar.gz" ] && break;
  bn=`basename $i .tar.gz`
  compr=gzip
  process $i 
done

for i in *.tar1.gz; do 
  [ "$i" == "*.tar1.gz" ] && break;
  bn=`basename $i .tar1.gz`
  compr=gzip
  process $i 
done

for i in *.tgz; do 
  [ "$i" == "*.tgz" ] && break;
  bn=`basename $i .tgz`
  compr=gzip
  process $i 
done

for i in *.tar.bz2; do
  [ "$i" == "*.tar.bz2" ] && break;
  bn=`basename $i .tar.bz2`
  compr=bzip2
  process $i 
done

for i in *.tar.lzop; do
  [ "$i" == "*.tar.lzop" ] && break;
  bn=`basename $i .tar.lzop`
  compr=lzop
  process $i 
done

for i in *.tar1.lzop; do
  [ "$i" == "*.tar1.lzop" ] && break;
  bn=`basename $i .tar1.lzop`
  compr=lzop
  process $i 
done

for i in *.tar; do
  [ "$i" == "*.tar" ] && break;
  bn=`basename $i .tar`
  compr=""
#  process $i 
  time tar tvf $i > flist--$bn.txt
done

for i in *.tar1; do
  [ "$i" == "*.tar1" ] && break;
  bn=`basename $i .tar1`
  compr=""
#  process $i 
  time tar tvf $i > flist--$bn.txt
done

        