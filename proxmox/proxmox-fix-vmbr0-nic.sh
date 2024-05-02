#!/bin/bash

# Try to fix vmbr0 / GUI access after a NIC name change
# 2024.May kneutron

cd /etc/network/
cp -v interfaces interfaces.$(date +%Y%m%d@%H%M).bak
cp -v interfaces interfaces.MODME

for iface in $(find /sys/class/net/en*); do
  ifacemac=$(cat $iface/address) 
  hascarrier=$(cat $iface/carrier) 
  shortiface=${iface##*/} # bash inline sed - we only need the end, strip off all */
# REF: https://tldp.org/LDP/abs/html/string-manipulation.html
  echo "$shortiface - MAC: $ifacemac - Has carrier signal: $hascarrier"
done 2>/dev/null |column -t

echo '====='
echo "Here is the current entry for vmbr0:"
grep -A 7 vmbr0 /etc/network/interfaces

oldiface=$(grep -m 1 bridge-ports /etc/network/interfaces |awk '{print $2}')
echo "This appears to be the OLD interface for vmbr0: $oldiface"

echo "Please enter which new interface name to use for vmbr0:"
read useinterface

sed -i "s/bridge-ports $oldiface/bridge-ports $useinterface/" interfaces.MODME

grep -m 1 bridge-ports interfaces.MODME
ls -lh /etc/network/interfaces /etc/network/interfaces.MODME

echo "The original interfaces file has been backed up!"
ls -lh *bak

echo "Hit ^C to backout, or Enter to replace interfaces file with the modified one and restart networking:"
read

cp -v interfaces.MODME interfaces
systemctl restart networking

ip a |grep vmbr0 |grep -v tap 

exit;


Difficulty: getting this onto your proxmox server
Solution: Copy script to USB disk or burn to ISO
Dont forget to ' chmod +x ' it before running it as root

===============
Example output:

# proxmox-fix-vmbr0-nic.sh
'interfaces' -> 'interfaces.20240502@1211.bak'
'interfaces' -> 'interfaces.MODME'
eno1    -  MAC:  20:7c:14:f2:ea:00  -  Has  carrier  signal:  1
eno2    -  MAC:  20:7c:14:f2:ea:01  -  Has  carrier  signal:  0
eno3    -  MAC:  20:7c:14:f2:ea:02  -  Has  carrier  signal:  0
eno4    -  MAC:  20:7c:14:f2:ea:3a  -  Has  carrier  signal:
enp4s0  -  MAC:  20:7c:14:f2:ea:04  -  Has  carrier  signal:  1
enp5s0  -  MAC:  20:7c:14:f2:ea:53  -  Has  carrier  signal:  1
enp6s0  -  MAC:  20:7c:14:f2:ea:06  -  Has  carrier  signal:  0
enp7s0  -  MAC:  20:7c:14:f2:ea:07  -  Has  carrier  signal:
enp8s0  -  MAC:  20:7c:14:f2:ea:a8  -  Has  carrier  signal:
=====
Here is the current entry for vmbr0:
auto vmbr0
iface vmbr0 inet static
        address 192.168.1.185/24
        gateway 192.168.1.1
        bridge-ports enp4s0
        bridge-stp off
        bridge-fd 0
#bridgeto1gbit

This appears to be the OLD interface for vmbr0: enp4s0
Please enter which new interface name to use for vmbr0:
eno1
        bridge-ports eno1
-rw-r--r-- 1 root root 1.7K Apr  1 14:52 /etc/network/interfaces
-rw-r--r-- 1 root root 1.7K May  2 12:12 /etc/network/interfaces.MODME
The original interfaces file has been backed up!
-rw-r--r-- 1 root root 1.7K May  2 12:04 interfaces.20240502@1204.bak
-rw-r--r-- 1 root root 1.7K May  2 12:11 interfaces.20240502@1211.bak
Hit ^C to backout, or Enter to replace interfaces file with the modified one and restart networking:
^C

[If you continue]
'interfaces.MODME -> interfaces'
3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vmbr0 state UP group default qlen 1000
5: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.1.186/24 scope global vmbr0
   
=====
    
You should now be able to ping 192.168.1.186 and get to the Proxmox Web interface.

NOTE - Script is a bit primitive, probably does not cover all network interface names, tested Ok in VM
Feedback is welcome :)

