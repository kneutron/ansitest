#!/bin/bash

# 2024.feb kneutron
# optional arg1 $1 = vmid if already known
# Assign cores 2-7 to boinc win10 6-core vm on 8-core host
# This should obviously be done on quad-core or better CPU

psax

declare -i vmid lastcpu penultcpu  # has to be a number

if [ "$1" = "" ]; then
  read -p "Enter VMID of highest-CPU kvm: " vmid
else
  vmid=$1
fi

[ "$vmid" = "" ] || [ "$vmid" = "0" ] && exit 44;

lastcpu=$(grep processor /proc/cpuinfo |tail -n 1 |awk '{print $3}')
let penultcpu=$lastcpu-1

# print only pid / subthreads that are using >0 CPU
pidlist=$(ps -eLf --columns $COLUMNS |grep "kvm -id $vmid" |egrep -v 'grep|bash' |awk '$5>0 {print $4}')
echo $pidlist

#exit; 

function assigncores () {
 
set -x
 taskset -p $1
 taskset -cp $penultcpu,$lastcpu $1
 
 taskset -cp $penultcpu $2
 taskset -cp $lastcpu $3
 let penultcpu=$penultcpu-1
 taskset -cp $penultcpu $4
 let penultcpu=$penultcpu-1
 taskset -cp $penultcpu $5
 let penultcpu=$penultcpu-1
 taskset -cp $penultcpu $6
 let penultcpu=$penultcpu-1
 taskset -cp $penultcpu $7
}
# assign cpu cores 6,7 to win10 vm for better latency
# REF: https://www.youtube.com/watch?v=-c_451HV6fE

# psthreads.sh 'kvm -id 112' |awk '$5>0 {print}' # field 4 is pid + subthreads

assigncores $pidlist

set +x
echo "Monitor changes with htop"

exit;

# Adapt to different multicore systems

# grep processor /proc/cpuinfo |tail -n 1
processor       : 7
# grep processor /proc/cpuinfo |tail -n 1 |awk '{print $3}'
7
