#!/bin/bash

# shared ISOs are mounted via samba from macpro on 2.5gbit network, R/O
# fstab:
# //macpro-25g/shrcompr-ztoshtera6  /mnt/imac5  cifs  noauto,noexec,credentials=/root/.smb-macpro,uid=root,ro 0 0

# Traverses subdirs on source and symlinks everything into 1 flat dir on proxmox
# 2024.Feb kneutron

# xxx TODO EDITME - destination dir for iso symlinks
# NOTE - default proxmox iso storage is /var/lib/vz
# faster ones here
cd /var/lib/vz/template/iso || exit 44; 

# grep iso at the end skips any misc non-iso files that were part of a torrent
# NOTE this is the samba mount
# NOTE this is 10Gbit samba mount to zint1000pro - faster
ln -sfn $(find /mnt/macpro-zint1000/ISO/ |grep iso$) . 
#ls -l
echo "Checking for broken symlinks:"
pwd; find . -xtype l

#cd /var/lib/vz/template/iso || exit 45; 
cd /mnt/seatera4-xfs/template/iso || exit 44; 
ln -sfn $(find /mnt/imac5/ISO/ |grep iso$) . 

# show broken/stale symlinks
pwd; find . -xtype l

exit;

# alternative:
[ $(which symlinks |wc -l) -eq 0 ] && apt install -y symlinks
symlinks -r . 

REF: https://www.reddit.com/r/Proxmox/comments/1aqn2sc/connecting_to_read_only_nfs_for_iso/

2024.0520 FIXED did not remove stale/broken symlinks - use midnight commander to detect them
REF: https://linuxhandbook.com/find-broken-symlinks/

#ln -sfn $(find /zseatera4mir/from-macpro-ztoshtera6/shrcompr-ztoshtera6/ISO/ |grep iso$) . 
# xxx 2024.0324, macpro was off most of the weekend
