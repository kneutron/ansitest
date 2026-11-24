#!/bin/bash

# 2026.Nov kneutron
# for osx

pingopts="-q -i 2 -c 2 " # osx
[ "$OSTYPE" = "cygwin" ] && pingopts="-n 2 "	# mobaxterm
#[[ "$OSTYPE" == *"linux"* ]] pingopts=$same as osx

echo "Using $pingopts"

goodping=0
badping=0

# RHEL VMs can reboot fast

#tput cup <row> <column>   

curcols=$(tput cols)
let xp=$curcols-18

function updt_pings () {
#  tput sc # Save the current cursor position

# line 1 toprt
  tput cup 0 $xp
  echo -n "GP: $goodping / BP: $badping"; tput el
  
  tput rc # Restore the cursor to the previously saved position
#  tput cuu 1 # go up 1 line
}

sdate=$(date)
echo "$sdate - Waiting for bad ping to start"
tput sc

#set -x
while [ $badping -lt 2 ]; do
#  ping -q -i 2 -c 2  "$1".local 2>&1 >/dev/null ;rc=$?

  ping $pingopts $1.local 2>&1 >/dev/null ;rc=$?
  [ $rc -ne 0 ] && ((badping++))
  [ $rc -eq 0 ] && ((goodping++))
  updt_pings
  sleep 2
done
#set +x

# 25 sec of good pings should be mostly-up
goodping=0
echo "$(date) - Waiting for good ping"
tput sc

while [ $goodping -lt 5 ]; do
  ping $pingopts $1.local 2>&1 >/dev/null ; rc=$?
  [ $rc -eq 0 ] && ((goodping++))
  [ $rc -ne 0 ] && ((badping++))
  updt_pings
  sleep 5
done
 
ndate=$(date)
echo "o Start $(basename $0) at $sdate; good ping at $ndate"

# DONE update gp / bp at top-right with tput
