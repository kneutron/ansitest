#!/bin/bash

# shared ISOs are mounted via samba from macpro on 2.5gbit network, R/O
# fstab:
# //macpro-25g/shrcompr-ztoshtera6  /mnt/imac5  cifs  noauto,noexec,credentials=/root/.smb-macpro,uid=root,ro 0 0

# Traverses subdirs on source and symlinks everything into 1 flat dir on proxmox
# 2024.Feb kneutron

# xxx TODO EDITME - destination dir for iso symlinks
# NOTE - default proxmox iso storage is /var/lib/vz
cd /mnt/seatera4-xfs/template/iso || exit 44; 

# NOTE local storage isos dir were renamed to iso-old

# grep iso at the end skips any misc non-iso files that were part of a torrent
# NOTE this is the samba mount
ln -sfn $(find /mnt/imac5/ISO/ |grep iso$) . 
ls -l

exit;

REF: https://www.reddit.com/r/Proxmox/comments/1aqn2sc/connecting_to_read_only_nfs_for_iso/

NOTE does not remove stale/broken symlinks - use midnight commander to detect them
