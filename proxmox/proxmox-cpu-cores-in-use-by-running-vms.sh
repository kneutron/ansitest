#!/bin/bash

# 2025.Apr kneutron
# REF: https://www.reddit.com/r/Proxmox/comments/1jzpttz/script_to_monitor_and_give_better_insight_with/

cd /etc/pve/qemu-server

echo "$(date) - CPU cores on this node $(hostname) = $(cat /proc/cpuinfo |grep -c ^processor)"
dmesg |egrep 'CPU topo: Allowing|smp: Brought up'
echo '====='
echo "$(date) - CPU Cores allocated by running VMs:"
grep ^cores $(qm list |grep running |awk '{print $1".conf"}') |awk -F' ' '{sum+=$2;} END{print sum;}'
echo '====='
cd /etc/pve/lxc/
echo "$(date) - CPU Cores allocated by running LXCs:"
grep ^cores $(pct list |grep running |awk '{print $1".conf"}') |awk -F' ' '{sum+=$2;} END{print sum;}'
echo '====='
uptime
free -h
echo '===== Storage sorted by Available space:'
pvesm status |head -n 1
pvesm status |grep -v Total |sort -n -k 6

exit;


Example output:

$0
Tue Apr 15 04:14:03 PM MDT 2025 - CPU cores on this node pve-beelink = 16
[    0.076714] CPU topo: Allowing 16 present CPUs plus 0 hotplug CPUs
[    0.362117] smp: Brought up 1 node, 16 CPUs
=====
Tue Apr 15 04:14:03 PM MDT 2025 - CPU Cores allocated by running VMs:
12
=====
Tue Apr 15 04:14:04 PM MDT 2025 - CPU Cores allocated by running LXCs:
9
=====
 16:14:04 up 5 days, 23:36,  9 users,  load average: 3.95, 4.26, 3.94
               total        used        free      shared  buff/cache   available
Mem:            62Gi        41Gi       5.7Gi       1.5Gi        17Gi        20Gi
Swap:          2.0Gi          0B       2.0Gi
=====
Name                                             Type     Status           Total            Used       Available        %
beelink-lex2txfs                                  dir     active       209612800        55518420       154094380   26.49%
local                                             dir     active        51290592        15069456        35156176   29.38%
local-lvm                                     lvmthin     active       252788736        35213470       217575265   13.93%
lvmthin2-internal                             lvmthin     active       836096000       642288947       193807052   76.82%
lvmthin3-lexar2t                              lvmthin     active       207613952        50325621       157288330   24.24%
lvmthin4-samt5                                lvmthin     active       483262464        34794897       448467566    7.20%
macmini2-sgtera2-proxmox-multi                    dir     active       976785944       526481124       450304820   53.90%
macpro-cifs-sgnas3tb                              dir   disabled               0               0               0      N/A
pbs-on-qotom-bkp-4-beelink                        pbs     active       471627760       309727284       161900476   65.67%
pbsvm-on-beelink-25g-smb-to-qotom-ztosh10         pbs     active      2469946368       292205568      2177740800   11.83%
pbsvm-on-beelink-25g-zlvmthin                     pbs     active       406421760       322829440        83592320   79.43%
pbsvm-on-beelink-zlexar2t                         pbs     active       838552560       137697408       700855152   16.42%
pbsvm-on-macmini2                                 pbs     active      1051630260       237178008       793045000   22.55%
qotom-proxmox-smb-exos10-xfs                      dir     active      4292880368      1307570452      2985309916   30.46%
using-my-own-vm-as-storage-lol-ext4               pbs     active       459715512       271820620       178514808   59.13%
zbeetle1t                                     zfspool     active       662437888       305179681       357258207   46.07%
zbeetle1t-proxmox-multi                           dir     active       358242304          985088       357257216    0.27%
zlexar2t                                      zfspool     active      1528037376       337725358      1190312018   22.10%
zlexar2t-proxmox-multi                            dir     active      1190312960            1024      1190311936    0.00%
zsamt7                                        zfspool     active       666501120       115850324       550650796   17.38%
zsamt7-proxmox-encrypted-lxc-storage          zfspool     active       567904964        17254168       550650796    3.04%
zsamt7-proxmox-multi                              dir     active       572514304        21864448       550649856    3.82%


=====

qm list |grep running
      100 pbs3-beelink         running    6144              16.00 3629
      108 win10-boinc-from-beelink-vmwr running    6144              50.00 4297
      123 suse-iscsi-bkp-4-macmini2 running    4096  40.00 5648
      126 truenas-scale-test   running    8192       16.00 6074

grep ^cores /etc/pve/qemu-server/100.conf
cores: 4
      
grep ^cores 100.conf 108.conf 123.conf 126.conf |awk -F' ' '{sum+=$2;} END{print sum;}'
12
