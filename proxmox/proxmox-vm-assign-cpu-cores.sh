#!/bin/bash

psax

declare -i pid # has to be a number
read -p "Enter PID of highest-RAM kvm: " pid

[ "$pid" = "" ] || [ "$pid" = "0" ] && exit 44;

taskset -p $pid
taskset -cp 6,7 $pid

# assign cpu cores 6,7 to win10 vm for better latency
# REF: https://www.youtube.com/watch?v=-c_451HV6fE
