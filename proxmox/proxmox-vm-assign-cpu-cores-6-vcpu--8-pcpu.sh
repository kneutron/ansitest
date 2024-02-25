#!/bin/bash

# 2024.feb kneutron
# optional arg1 $1 = vmid if already known
# Assign cores 2-7 to boinc win10 6-core vm on 8-core host
#   OR Assign cores 7-5 to boinc win10 3-core vm on 8-core host

# Features:
# Auto-determines last core number
# Adapts on-the-fly to 2,3+ vcpus (up to 6) as long as cpu usage is > 0
#   Can be extended easily for more vcpu counts
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
 
 taskset -cp $lastcpu $2
 taskset -cp $penultcpu $3
 
 let penultcpu=$penultcpu-1
[ "$4" = "" ] || taskset -cp $penultcpu $4
 let penultcpu=$penultcpu-1
[ "$5" = "" ] || taskset -cp $penultcpu $5
 let penultcpu=$penultcpu-1
[ "$6" = "" ] || taskset -cp $penultcpu $6
 let penultcpu=$penultcpu-1
[ "$7" = "" ] || taskset -cp $penultcpu $7
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

===== Example output:

# proxmox-vm-assign-cpu-cores-6-vcpu--8-pcpu.sh 112                                                                                          [17/39]
 11:59:53 up 4 days, 15:12,  8 users,  load average: 3.03, 2.72, 2.93
    PID USER      NI %CPU PSR %MEM COMMAND
1634464 root       0  187   7 37.5 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -chardev soc
1290029 root       0 10.3   1 11.5 /usr/bin/kvm -id 108 -name squidvm-2p5gig-10gig-HO-fasterstorage,debug-threads=on -no-shutdown -c
 607603 root       0  6.0   3  2.6 /usr/bin/kvm -id 111 -name ipfire-dhcp-for-10gig,debug-threads=on -no-shutdown -chardev socket,id
 577386 root       0  5.7   2  9.7 /usr/bin/kvm -id 109 -name opnsense-dhcp-for-2p5Gbit,debug-threads=on -no-shutdown -chardev socke
     68 root       5  3.8   0  0.0 [ksmd]
 222982 root       0  2.6   1  6.9 /usr/bin/kvm -id 104 -name pfsense-272-dhcp-for-HO,debug-threads=on -no-shutdown -chardev socket,
1451426 dave       0  2.0   1  0.0 htop -d 22
   2326 root       0  1.4   3  0.3 pvestatd
1631891 root       0  0.4   1  0.3 pvedaemon worker
   2327 root       0  0.4   2  0.3 pve-firewall
1641323 root       0  0.3   3  0.0 -bash 
1633442 root       0  0.3   0  0.2 pvedaemon worker
     67 root       0  0.3   4  0.0 [kcompactd0]
    129 root       0  0.3   1  0.0 [kswapd0]
1633341 www-data   0  0.3   0  0.9 pveproxy worker
1636452 www-data   0  0.2   3  0.8 pveproxy worker
1633109 www-data   0  0.2   0  0.9 pveproxy worker
1641322 root       0  0.1   1  0.0 tmux
   3189 root       0  0.1   7  0.0 /usr/bin/top -d 15
1635124 root       0  0.1   6  0.8 /usr/bin/perl /usr/sbin/qm vncproxy 112
1627107 root     -20  0.1   3  0.0 [zvol]
               total        used        free      shared  buff/cache   available 
Mem:        16344068    13051672     1248048       39920     2560400     3292396 
Swap:        2097148      682412     1414736
1634464 1634537 1634538 1634539
+ taskset -p 1634464
pid 1634464's current affinity mask: c0
+ taskset -cp 6,7 1634464
pid 1634464's current affinity list: 6,7
pid 1634464's new affinity list: 6,7
+ taskset -cp 7 1634537
pid 1634537's current affinity list: 7
pid 1634537's new affinity list: 7
+ taskset -cp 6 1634538
pid 1634538's current affinity list: 6
pid 1634538's new affinity list: 6
+ let penultcpu=6-1
+ '[' 1634539 = '' ']'
+ taskset -cp 5 1634539
pid 1634539's current affinity list: 5
pid 1634539's new affinity list: 5
+ let penultcpu=5-1
+ '[' '' = '' ']'
+ let penultcpu=4-1
+ '[' '' = '' ']'
+ let penultcpu=3-1
+ '[' '' = '' ']'
+ set +x
Monitor changes with htop
