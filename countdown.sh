#!/bin/bash

# 2020 Dave Bechtel
# Display a rotating-prompt countdown with keypress early escape
# REF: https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator

# number
declare -i countto=$1
ctr=0

# array
declare -a spin
spin[0]="-"
spin[1]='\'
spin[2]="|"
spin[3]="/"

echo -n "[$countto] ${spin[0]} " #$ctr"

while [ $countto -ge $ctr ]; do
  for i in "${spin[@]}"
  do
	let cdown=$countto-$ctr
	printf "\r$countto $i $cdown     "
        sleep 1
	let ctr=$ctr+1
	[ $ctr -ge $countto ] && break
	read -n 1 -t .1 && break 2
# ESC if key pressed
  done
done
echo ''
