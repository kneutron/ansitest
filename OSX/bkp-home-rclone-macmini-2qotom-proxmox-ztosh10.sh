#!/bin/bash

# bkp macmini home to qotom proxmox ztosh10
# REF: https://rclone.org/sftp/
#eval `ssh-agent -s` && ssh-add -A
eval `ssh-agent -s` && ssh-add -k ~/.ssh/id_rsa 

# dest: /Volumes/zsgtera2/shrcompr-bkphome-zsgtera2/bkphome-macpro2-lmde6

date
# -i = interactive
# skip -- --copy-links
# -c = check hashes
# REF: https://rclone.org/sftp/#sftp-disable-hashcheck 
# ^REF: https://forum.rclone.org/t/ignore-checksum-not-honored/13397/3

# xfrs=3 single disk increased to 6 for mirror 2024.0413
# REMEMBER shr/notshr are SYMLINKS, dont dup content!
#time rclone sync -P --copy-links --retries=2 --low-level-retries=2 \
#time rclone sync -P --skip-links --delete-before --retries=2 --low-level-retries=2 \
#  --exclude=dvdrips-shr/** --exclude=.fseventsd/** \
time rclone sync -P --skip-links --retries=2 --low-level-retries=2 \
  --sftp-disable-hashcheck \
  --transfers=3 --stats=2s \
  --no-update-modtime --update \
  /Users/ \
  qotom-proxmox-25g:/ztoshtera10/bkp-home-macmini-rclone \
  --log-file ~/bkp-home-rclone-macmini-errors.log 
# 2>~/rclone-error.log

date
eval `ssh-agent -k`

exit;

o Run rclone config to setup.  See rclone config docs (https://rclone.org/docs/) for more details.
Type: 47 / SSH/SFTP Connection

NOTE REQUIRES ssh-copy-id dave@ip 1st!!

REF: A note on exclude-
https://rclone.org/filtering/

REF: Helpful tips:
https://dshark3y.medium.com/the-best-tool-youre-not-using-15ba2d238515

No worky:
  10.9.7.12:/zwd6t/bkp-osx-zsgtera4/zsgtera4 \
