#!/bin/bash

pname=zsgtera4compr

zpool create -f -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $pname \
  mirror ata-ST4000VN000-1H4168_Z3073Z29 ata-ST4000VN000-1H4168_Z306G0K3 \
  mirror ata-ST4000VN000-1H4168_Z3073ZAY ata-ST4000VN000-1H4168_Z306G7H8
    
pdir=tkita; zfs create -o atime=off -o sharesmb=on $pname/$pdir; chown tkita:dave /$pname/$pdir
ls -al /$pname/$pdir
    
zpool status
    
(set -r
smbpasswd -a tkita
)
    