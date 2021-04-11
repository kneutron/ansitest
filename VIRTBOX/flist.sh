#!/bin/bash

# Go thru .tar.gz, .tar.bz2 in dir and list them to flist-file
# This generally lives in /usr/local/bin since non-root can call it
# DEPENDS: gzip, bzip2, lzop, tar

function process () {
  args=$*
  echo $args

# if doing rezip, renice bzip2
renice +1 $(pidof bzip2) 2>/dev/null

# Preserve existing output
  if [ -e "flist--$bn.txt" ]; then                                                                       
    echo "* Skipped $bn"
  else                                                                                                    
    time $compr -cd $args |tar tvf - > flist--$bn.txt
  fi
}

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

# TODO zstd
# 2014(?)-2021 Dave Bechtel        
