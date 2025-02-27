#!/bin/bash

# Traverses subdirs on SMB net share and symlinks everything into 1 flat dir on proxmox
# Saves on ISO storage space across PVE nodes
# 2024.Feb kneutron / edits 2024.Nov

# shared ISOs are mounted via samba from macpro on 2.5gbit network, R/O
# fstab:
# //macpro-25g/shrcompr-ztoshtera6  /mnt/imac5  cifs  noauto,noexec,credentials=/root/.smb-macpro,uid=root,ro 0 0

# NOTE Pass "1" as arg to auto-delete broken symlinks

# Rerun the script on each PVE node if you update / delete ISOs on the share / run nightly in cron

# for cron
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

# Example root crontab entry:
# every day @ 11:01pm, refresh ISO symlinks and autodelete stale ones 
#1  23  *  *  *  /root/bin/boojum/symlink-samba-isos.sh 1 2>&1 >/root/symlink-samba-isos.log

# TODO set to 0 if you only have 1 shared ISO dir
enable2nddir=0

# Destination dir for iso symlinks
# NOTE - default proxmox iso storage is /var/lib/vz
# faster ones here
cd /var/lib/vz/template/iso || exit 44; 

# grep iso at the end skips any misc non-iso files that were part of a torrent
# NOTE this is 2.5Gbit samba mount to zint1000pro - faster
# only if mounted, otherwise skip
# xxx TODO EDITME
mnt=macpro-zint1000
if [ $(df |grep -c $mnt) -gt 0 ]; then
  ln -sfn $(find /mnt/$mnt/ISO/ |grep iso$) . 
#ls -l
  echo "o Checking for broken symlinks:"
  pwd
  if [ "$1" = "1" ]; then
    echo "o Auto-deleting broken symlinks per arg passed"
    find . -xtype l -print -delete # autofix broken sym
  else
# display only, admin needs to fix
    find . -xtype l 
  fi # if autofix broken symlinks
#  find . -xtype l -exec rm -v {} \; # fix broken sym
fi # if df

if [ $enable2nddir -gt 0 ]; then
# secondary ISO dir [optional]
# This is the destination dir on pve - xxx TODO EDITME
  cd /mnt/seatera4-xfs/template/iso || exit 44; 
# this is the samba mount - xxx TODO EDITME
  mnt=imac5
  if [ $(df |grep -c $mnt) -gt 0 ]; then
    echo '====='
    echo "o Symlinking 2nd dir $mnt to $PWD"
    ln -sfn $(find /mnt/$mnt/ISO/ |grep iso$) . 
# show broken/stale symlinks
    pwd
    echo "o Checking for broken symlinks from $mnt:"
    if [ "$1" = "1" ]; then
      echo "o Auto-deleting broken symlinks per arg passed"
      find . -xtype l -print -delete # fix broken sym
    else
# display only, admin needs to fix
      find . -xtype l 
    fi # if autofix broken symlinks
  fi # if df
fi # if 2nd dir

exit;

# alternative:
#[ $(which symlinks |wc -l) -eq 0 ] && apt install -y symlinks
#symlinks -r . 

#REF: https://www.reddit.com/r/Proxmox/comments/1aqn2sc/connecting_to_read_only_nfs_for_iso/

#2024.0520 FIXED did not remove stale/broken symlinks - use midnight commander to detect them
#REF: https://linuxhandbook.com/find-broken-symlinks/

#ln -sfn $(find /zseatera4mir/from-macpro-ztoshtera6/shrcompr-ztoshtera6/ISO/ |grep iso$) . 
# xxx 2024.0324, macpro was off most of the weekend

# NOTWORK
#argdel=""
#[ "$1" = "1" ] && argdel="-exec rm -v {} \;" # fix broken sym
