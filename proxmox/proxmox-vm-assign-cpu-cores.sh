#!/bin/bash

# 2024.feb kneutron
# optional arg1 $1 = vmid if already known
# Assign cores 6,7 to boinc win10 2-core vm

psax

declare -i vmid # has to be a number
if [ "31" = "" ]; then
  read -p "Enter VMID of highest-CPU kvm: " vmid
else
  vmid=$1
fi

[ "$vmid" = "" ] || [ "$vmid" = "0" ] && exit 44;

pidlist=$(ps -eLf --columns $COLUMNS |grep "kvm -id $vmid" |egrep -v 'grep|bash' |awk '$5>0 {print $4}')
echo $pidlist

#exit; 

function assigncores () {
 
set -x
 taskset -p $1
 taskset -cp 6,7 $1
 
 taskset -cp 6 $2
 taskset -cp 7 $3
}
# assign cpu cores 6,7 to win10 vm for better latency
# REF: https://www.youtube.com/watch?v=-c_451HV6fE

# psthreads.sh 'kvm -id 112' |awk '$5>0 {print}' # field 4 is pid + subthreads

assigncores $pidlist

echo "Monitor changes with htop"

