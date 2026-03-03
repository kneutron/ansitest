#!/bin/bash

# REF: https://forum.proxmox.com/threads/how-to-enable-continuous-time-sync-between-qemu-guest-and-host.173396/#post-806460

cconf=/etc/chrony/chrony.conf
if ! [ -e $cconf ]; then
  cconf=/etc/chrony.conf
fi
if ! [ -e $cconf ]; then
  echo "Chrony conf file not found in usual locations!"
  exit 44;
fi

declare -i argg=$1
# NOTE pass 1 as arg to override
result=$(lspci |grep -c qemu)
if [ $result -eq 0 ] && [ $argg -ne 1 ]; then
  echo "Run this in-vm!!"
  exit 101
fi

# Set the ptp_kvm module to load after reboot.

echo ptp_kvm > /etc/modules-load.d/ptp_kvm.conf
modprobe ptp_kvm
lsmod |grep -c ptp_kvm

# Add the /dev/ptp0 clock as a reference to the chrony configuration:

[ $(grep -ci refclock $cconf) -eq 0 ] &&  echo "refclock PHC /dev/ptp0 poll 2" >> $cconf

# [*]Restart the chrony daemon:

systemctl restart chronyd
systemctl status  chronyd

chronyc sources -av
