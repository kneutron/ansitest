#!/bin/sh

# 2025.Jul bechteld
fyl=/tmp/vms-autostart.list
allvmsfyl=/tmp/allvms-tmp.list

echo "$(date) - Getting info"
vim-cmd hostsvc/autostartmanager/get_autostartseq |egrep 'key|startOrder' >$fyl
vim-cmd vmsvc/getallvms > $allvmsfyl

cat $fyl
echo '====='

for vmidt in $(awk -F: 'NF>0 {print $2}' $fyl); do
  [ "$vmidt" = "" ] && continue;
#  echo '.'$vmidt'.' # debugg

  quot="'"
  vmid=$(echo "$vmidt" |sed 's/'$quot',//g') # no 'tr'
  [ "$vmid" = "" ] && continue;
# remove ',

#  echo ','"$vmid"',' # debugg
  grep -w "^$vmid" $allvmsfyl |head -n 1 |awk '{print $1"\t",$2"\t",$4"\t",$5}'
done

date
exit;

      key = 'vim.VirtualMachine:2',
      startOrder = 1,
      key = 'vim.VirtualMachine:1',
      startOrder = 2,
      key = 'vim.VirtualMachine:4',
      startOrder = 3,
      key = 'vim.VirtualMachine:6',
      startOrder = 4,
=====
2        pihole-squid    pihole-squid/pihole-squid.vmx   debian11_64Guest
1        zfs-samba       ubuntu-zfs-samba/ubuntu-zfs-samba.vmx   ubuntu64Guest
4        ntpserver       ntpserver/ntpserver.vmx         ubuntu64Guest
6        winserver2022   winserver2022/winserver2022.vmx         windows2019srv_64Guest
