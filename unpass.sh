#!/bin/bash

# Loop through the range of 0 - 99999 to find the 5-number passcode for a 7zip archive
# REF: https://www.reddit.com/r/bash/comments/zey4h8/finding_a_5_digit_code_for_a_locked_zip_file/

# https://youtu.be/B-NhD15ocwA?t=71
# :B

# Starts 2x parallel jobs, one counts up - the other counts down
# NOTE everything including the .7z file is in /dev/shm (ramdisk) for speed

# TESTs archive ONLY, does not extract it - but should give you the correct code if it finds it

# REQUIRES: tee, 7z, seq
# killall assumes Linux, other broken implementations may do the wrong thing

logf=/dev/shm/unpass.log
#archive=yxor.7z # leaving hardcoded for processing speed, only vars we really need are counternum and passcode
date >$logf

foundit () {
  echo "$(date) FOUND IT $i $j" |tee -a $logf
  cat /dev/shm/currentcode /dev/shm/currentcode2
  ls -l
#  exit 0
  killall 7z
  killall $(basename $0)
}

# if the password is in the 54000 range, shortcut to speed up testing
#for i in $(seq -w 54000 55000); do
for i in $(seq -w 0 49999); do
	echo $i >/dev/shm/currentcode # use ramdisk 
	7z t -p$i yxor.7z 2>&1>/dev/null ; [[ $? -eq 0 ]] && foundit # break
done &

for j in $(seq -w 99999 -1 50000 ); do
        echo $j >/dev/shm/currentcode2 # use ramdisk 
        7z t -p$j yxor.7z 2>&1>/dev/null ; [[ $? -eq 0 ]] && foundit
done &

wait;

echo "$(date) - DID NOT FIND CODE" |tee -a $logf

exit;

# 2022.1207 kingneutron
# To monitor the current password code, in another terminal:
# $ while :; do cat /dev/shm/cur*; sleep 9; done	# ^C to quit this (do forever)
#
# Doing this does not slow down the processing
