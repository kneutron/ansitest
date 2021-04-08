#!/bin/bash

echo "Getting sorted list of installed pkgs..."
date

rpm -qa |sort >~/Installedpkgs.list
echo EOF>>~/Installedpkgs.list

echo "Done with sort"
date

let tr=1
let thisline=0

echo "Reading sorted list into array..."
{
 while read elemt; do
  let thisline=$thisline+1

  # Skip comments
  commentmp=`(echo $elemt |grep -c -e "\#")`
  test4blank=${elemt//" "/""}

  if [ $commentmp -gt 0 ]; then
    echo "Found a comment in line "$thisline".  Skipping."
  elif [ ${#test4blank} -eq 0 ]; then
    echo "Blank line at "$thisline".  Skipping."
  elif [ "$elemt" = "EOF" ]; then
    echo "EOF found in line "$thisline"."
    break
  else
    riptrack[$tr]=$elemt
    let tr=$tr+1
  fi

 done
} < ~/Installedpkgs.list
echo "Done with array = "$tr" elements."
date

# Repeat array
#for i in "${riptrack[@]}"; do
# echo $i
#done

# Blank it
>~/RPMInstalled.list

echo "Querying all installed pkgs for details..."
# Do it
for i in "${riptrack[@]}"; do
 rpm -qi $i >>~/RPMInstalled.list
done

echo "Done- PK"
date
#read
#less ~/RPMInstalled.list
