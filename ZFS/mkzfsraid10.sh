#!/bin/bash

# Example create 4-drive mirror pool, create and chown a samba shared dataset and associated userid for it
# userid needs to exist (useradd/adduser) first

zp=zsgtera4compr

zpool create -f -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
  mirror ata-ST4000VN000-1H4168_Z3073Z29 ata-ST4000VN000-1H4168_Z306G0K3 \
  mirror ata-ST4000VN000-1H4168_Z3073ZAY ata-ST4000VN000-1H4168_Z306G7H8
    
pdir=dave; zfs create -o atime=off -o sharesmb=on $zp/$pdir; chown $pdir:dave /$zp/$pdir
ls -al /$pname/$pdir
    
zpool status
    
(set -r
smbpasswd -a $pdir
)
    
