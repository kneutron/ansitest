#!/bin/sh

# 2026.Feb bechteld.adm

# gen report 1st
/root/bin/get-poweredoff-vms.sh

infile=/root/vmcpus.txt

cd /vmfs/volumes/VMHOST02-LocalStorage
pwd
echo "$(date) - Getting number of allocated cpus per-vm"
find . -name "*.vmx" -print -exec grep numvcpus {} \; >$infile

sed -i 's/"//g' $infile
# remove quot

echo '====='
echo "o Allocated vcpus in .vmx files (all):"
awk -F= '{sum += $2} END {print sum}' $infile
echo '---'
echo "NOTE Subtract CPUs from powered-off VMs:"
awk -F= '{sum += $2} END {print sum}' /root/poweredoffcpus.txt

