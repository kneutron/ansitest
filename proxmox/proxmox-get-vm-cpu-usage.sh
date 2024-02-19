#!/bin/bash

# 2024.feb kneutron
# Get main process + subthread(s) CPU usage for multi-core VM

echo "Usage: pass arg \$1 as VM number from GUI"
time qm list |egrep 'VMID|running' |column -t

declare -i arg # must be a number
[ "$1" = "" ] || [ "$1" = "0" ] && exit 44;
arg=$1
#echo "arg=$arg" # debugg
[ "$arg" = "0" ] && exit 44;

ps -eLf --width $COLUMNS|grep 'kvm -id '$arg |sort -r -k 5 
exit;

# ps -eLf --width $COLUMNS|grep 'kvm -id 112' |sort -r -k 5
#	 parent pid      thread  CPU%				 commandline (short)
root     2538336       1 2538336 99   11 13:34 ?        05:51:12 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538416 75   11 13:34 ?        02:49:29 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538417 74   11 13:34 ?        02:47:28 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2589324   34849 2589324  0    1 17:19 pts/2    00:00:00 grep kvm -id 112
root     2538336       1 2588496  0   11 17:15 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2588296  0   11 17:14 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2574510  0   11 16:15 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538481  0   11 13:34 ?        00:00:27 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538482  0   11 13:34 ?        00:00:23 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538338  0   11 13:34 ?        00:00:01 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538420  0   11 13:34 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
root     2538336       1 2538337  0   11 13:34 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-test-network-install,debug-thre
#1	 2	       3 4	 5	

# This is handy as you can pass the PIDs of the top cpu users to tasksel / assign cores
# In the above case it would be 2538336, 2538416, 2538417 -- as enumerated by 'htop'
