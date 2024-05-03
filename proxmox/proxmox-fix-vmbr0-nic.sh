#!/bin/bash

# Try to fix vmbr0 / GUI access on IP:8006 after a NIC name change
# 2024.May kneutron

# DEPENDS: find grep awk sed netstat

# PROTIP - run ' screen ' or ' tmux ' before running this script if the interface name is long,
#   you can copypasta with just the keyboard - see appropriate man pages

# In GNU screen: Hit ^[, cursor move to start of new interface name, hit spacebar to begin mark, cursor to end of NIC name, 
#   then hit spacebar to end mark, ^] to paste

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

echo '====='
echo "Please enter which new interface name to use for vmbr0:"
read useinterface
echo ''
echo "Replacing $oldiface with $useinterface in temporary MODME file - NOTE you are just modifiying a copy,"
echo "  the original interfaces file is still in place"
echo ''
echo "NOTE no fix has actually been implemented yet, you can still back out"

# not global, only 1st match
sed -i "s/bridge-ports $oldiface/bridge-ports $useinterface/" interfaces.MODME

echo '====='
grep -m 1 bridge-ports interfaces.MODME
ls -lh /etc/network/interfaces /etc/network/interfaces.MODME

echo '====='
echo "NOTE The original interfaces file has been backed up!"
ls -lh *bak

echo '====='
echo "Nothing has been modified / fixed yet, you are still in safe mode"
echo "Hit ^C to backout, or Enter to replace the interfaces file with the fixed one and restart networking:"
read


# Teh Main Thing
echo ''
echo "$(date) - Applying the fix"
cp -v interfaces.MODME interfaces
echo "$(date) - Restarting networking service to apply the change"
time systemctl restart networking

echo "$(date) - Restarting pveproxy service to make sure port 8006 is listening"
time systemctl restart pveproxy
# probably not necessary, but why not

# verify web GUI listening port
netstat -plant |grep 8006 |head -n 2

echo '====='
ip a |grep vmbr0 |grep -v tap 

echo "You should now be able to ping the above IP address and get to the Proxmox Web interface."
date;

exit;

===================

Difficulty: getting this script onto your proxmox server without network
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

NOTE - Script is a bit primitive, makes several assumptions about interfaces file being in a certain order,
  probably does not cover all network interface names, tested Ok in VM

Feedback is welcome :)

=====

Written for PVE 8.2.2, may work with other versions

V2 - extra text, formatting, commenting, features - restart pveproxy and check for listening 8006 port
Reassure end-user that no changes are actually being implemented until they hit enter to confirm
