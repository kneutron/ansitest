#!/bin/sh

# esxi script - 2025.Nov bechteld.adm
# get all VM MAC addresses

cd /vmfs/volumes/3aad31c1-9ba16698-b814-1402ecdbe850

(find . -name *.vmx -print -exec grep 'ddress =' {} \;) > /root/macs.txt
sed 's/://g' macs.txt >/root/macs-nosep.txt

ls -lh /root/macs*

# find a subset:
# grep -i -A 1 rhelbldr macs-nosep.txt

##./rhelbldr12/rhelbldr12.vmx
##ethernet0.generatedAddress = "000c29817c9b"

