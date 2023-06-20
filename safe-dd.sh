#!/bin/bash

# REF: https://distrowatch.com/weekly.php?issue=20230619#tips
# Some mods by kneutron 2023Jun

# WRAPPER - This script invokes the dd command to copy a file. 
# It first checks to make sure the target file (of) is not mounted.
# Warning, this may not work with device names containing a space.

if [ $# -lt 2 ]
then
  echo "Please provide an input file and an output file."
  exit 1
fi

start=$(echo $@ | sed 's/of=/\^/')
end=$(echo $start | cut -f 2 -d '^')
target=$(echo $end | cut -f 1 -d ' ')

echo "Checking $target"
df | grep $target
if [ $? -eq 0 ]
then
  echo "Output file $target is mounted. Refusing to continue."
  exit 2
fi

echo "Executing nice dd $@ status=progress"
time /usr/bin/dd $@ bs=1M status=progress
sync
echo "$(date) - Finished writing and sync."
