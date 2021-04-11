#!/bin/bash

# DEPENDS: pv, tar, flist.sh, /root/bin/boojum/BKPDEST.mrg (up to date with valid destination dir)

source /root/bin/boojum/BKPDEST.mrg     # now provides mount test
bkpath=$bkpdest/notshrcompr

pathh="$bkpath/bkp-home"
mkdir -p -v $pathh
cd $pathh || failexit 199 "! Could not CD to $pathh";
ls -lh

bkpdate=$(date +%Y%m%d)
bkpfname="bkp-home--$myhn--NORZ--$bkpdate"

# free up some space 1st
# http://bashshell.net/utilities/find-with-multiple-expressions/
# find with OR == works
 
#cd $pathh && find $pathh/* -type f -mtime +28 -exec rm {} \;
# !! find bkp-gz and flist files more than 20 days old and delete
# SKIP, shared dir with multiple home sources
#echo 'o Autocleaning old bkps for free space'
#cd $pathh && \
#   find $pathh/* \( -name "bkp*gz" -o -name "bkp*bz2" -o -name "bkp*lzop" -o -name "flist*" \) -type f -mtime +20 -exec /bin/rm -v {} \;

echo "==Backing up HOME to $pathh"
df -hT /home $bkpdest

# comprdest
time tar \
  -cpf - /home/* \
  | pv -t -r -b -W -i 2 -B 50M \
  > $bkpfname.tar
#  | lzop \
#  > $bkpfname.tar.lzop 

ls -lh
pwd
#echo $pathh

# fire off in BG
flist.sh &
#time tar tzvf $bkpfname.tar1.gz > flist--$bkpfname.txt &

echo "$0 done - $(date)"
