#!/bin/bash

# "say" requires OSX for speech synth
# Use ssh-copy-id beforehand for PWless login

# xxx TODO EDITME
#tryip="10.0.4.21" # mx21
tryip="10.9.0.4" # squid
user=dave

echo "$tryip"

function countdown () {
# REF: https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator

#pid=$! # Process Id of the previous running command

# number
 declare -i countto=$1
 ctr=0

 declare -a spin
 spin[0]="-"
 spin[1]='\'
 spin[2]="|"
 spin[3]="/"

 echo -n "[$countto] ${spin[0]} " #$ctr"
#while [ kill -0 $pid ]
 while [ $countto -ge $ctr ]; do
   for i in "${spin[@]}"
   do
#        echo -ne "\b$i $ctr"
 	let cdown=$countto-$ctr
 	printf "\r$countto $i $cdown     "
         sleep 1
 	let ctr=$ctr+1
 	[ $ctr -ge $countto ] && break
 	read -n 1 -t .1 && break 2
   done
 done
echo ''
}

# do a countdown if waiting for boot
if [ "$1" = "1" ]; then
  date
  countdown 150 # 250 # 360
  which say && say -v Fiona "check monitor" 

#  ping -o 10.0.2.34
# do forever
  while :; do
    for ip in $tryip; do
      echo "Trying IP $ip"
      ping -c 5 $ip && break 2
    done
  done

  which say && say -v Fiona "Attempting log in $ip" &
  date
  ssh -2 -X -Y -c chacha20-poly1305@openssh.com -l $user $ip # 10.0.2.34
 # fryserver
else
# NOTE does not need static ip
#autossh -M 32500 -2 -X -Y -l $user p2700quad1404
  ssh -2 -X -Y -c chacha20-poly1305@openssh.com -l $user $tryip # 10.0.2.34
 # fryserver
fi
