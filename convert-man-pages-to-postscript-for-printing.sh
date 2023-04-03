#!/bin/bash

# REF: https://distrowatch.com/weekly.php?issue=current
# REF: https://stackoverflow.com/questions/28357997/running-programs-in-parallel-using-xargs/28358088#28358088

cd
mkdir -pv Printable-Manual-Pages ; cd Printable-Manual-Pages
pwd

#time find /usr/share/man/man? -type f -print0 |gxargs -0 -t -I % -n 1 -P $(nproc) manTtoPS.sh % # "man -t "%" > $(basename "%").ps"

time find /opt/local/man/man? -type f -print0 |gxargs -0 -t -I % -n 1 -P $(nproc) manTtoPS.sh % # "man -t "%" > $(basename "%").ps"

du -s -h 
date

exit;

for page in $(find /usr/share/man/man? -type f); do 
 echo "Processing $page"
 man -t "$page" > $(basename "$page").ps
done
