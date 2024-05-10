#!/bin/bash

# Display container actual disk usage/free
# NOTE the container does NOT have to be running
# 2024.May kneutron

for ctr in $(pct list |grep -v VMID |awk '{print $1}'); do
  echo "LXC CTR: $ctr"
  pct df $ctr
  echo '====='
done

exit;

Example output:

# $0 |column -t

LXC     CTR:                                105                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  dir1:105/vm-105-disk-1.raw          1.9G    653.8M  1.1G    33.6  /
=====                                                                     
LXC     CTR:                                110                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  zfs3nvme1T:subvol-110-disk-1        21.0G   1.5G    19.5G   7.1   /
mp0     /mnt/seatera4-xfs/bindmt-container  3.6T    1.4T    2.2T    39.1  /mnt/bindhost-xfs
mp1     zfs1:subvol-110-disk-0              235.0G  83.7G   151.3G  35.6  /zdisk1-iscsi
=====                                                                     
LXC     CTR:                                113                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  zfs3nvme1T:subvol-113-disk-0        4.0G    1.7G    2.3G    41.8  /
=====                                                                     
LXC     CTR:                                114                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  zfs3nvme1T:subvol-114-disk-0        4.0G    1.7G    2.3G    43.7  /
=====                                                                     
LXC     CTR:                                118                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  zfs2nvme:subvol-118-disk-0          8.0G    629.0M  7.4G    7.7   /
mp0     zfs3nvme1T:subvol-118-disk-0        50.0G   39.1G   10.9G   78.2  /mnt/proxmox-ctr-share
=====                                                                     
LXC     CTR:                                122                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  zfs1:subvol-122-disk-0              6.0G    413.6M  5.6G    6.7   /
=====                                                                     
LXC     CTR:                                124                           
MP      Volume                              Size    Used    Avail   Use%  Path
rootfs  local-lvm:vm-124-disk-0             4.8G    729.7M  3.9G    14.7  /
=====                                                                     


# pct df 118
MP     Volume                        Size   Used Avail Use% Path
rootfs zfs2nvme:subvol-118-disk-0    8.0G 629.0M  7.4G  7.7 /
mp0    zfs3nvme1T:subvol-118-disk-0 50.0G  39.1G 10.9G 78.2 /mnt/proxmox-ctr-share

# pct list
VMID       Status     Lock         Name                
105        running                 gotify              
110        stopped                 suseleap-ctr-p      
113        stopped                 debian-ctr          
114        stopped                 debianctr-xorgtest  
118        running                 proxmox-fileserver-ctr
122        stopped                 test-phone-tether   
124        stopped                 debian-qdevice-dellap
