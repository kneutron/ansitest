#!/bin/bash

# for RPM-based distros
# get detailed installed-packages info

echo "Getting sorted list of installed pkgs..."
date

time rpm -qa |sort >~/Installedpkgs.list
#echo EOF>>~/Installedpkgs.list

echo "$(date) - Done with sort"

# Blank it
outfile=~/RPMInstalled.list.txt
> $outfile

echo "Querying all installed pkgs for details..."
# Do it
for i in $(cat ~/Installedpkgs.list); do
 rpm -qi $i >>$outfile
done

echo "$(date) - Done"
#less ~/RPMInstalled.list
ls -alh $outfile

exit;

# 2021.0408 rewrite simpler
