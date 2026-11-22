#!/bin/bash

# 2026.Nov kneutron
# for osx

goodping=0
badping=0

# RHEL VMs can reboot fast

#tput cup <row> <column>   

curcols=$(tput cols)
let xp=$curcols-18

function updt_pings () {
  tput sc # Save the current cursor position

# line 1 toprt
  tput cup 0 $xp
  echo -n "GP: $goodping / BP: $badping"; tput el
  
  tput rc # Restore the cursor to the previously saved position
}

sdate=$(date)
echo "$sdate - Waiting for bad ping to start"
while [ $badping -lt 2 ]; do
  ping -q -i 2 -c 2  "$1".local 2>&1 >/dev/null ;rc=$?
  [ $rc -ne 0 ] && ((badping++))
  [ $rc -eq 0 ] && ((goodping++))
  updt_pings
  sleep 2
done

# 25 sec of good pings should be mostly-up
goodping=0
echo "$(date) - Waiting for good ping"
while [ $goodping -lt 5 ]; do
  ping -q -c 2  "$1".local 2>&1 >/dev/null ; rc=$?
  [ $rc -eq 0 ] && ((goodping++))
  [ $rc -ne 0 ] && ((badping++))
  updt_pings
  sleep 5
done
 
ndate=$(date)
echo "o Start $(basename $0) at $sdate; good ping at $ndate"

# DONE update gp / bp at top-right with tput
