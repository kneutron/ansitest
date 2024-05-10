#!/bin/bash

# REF: https://www.reddit.com/r/Proxmox/comments/tfbhp1/newbie_here_what_are_the_benefits_of_proxmox/
# REF: https://pbs.proxmox.com/docs/backup-client.html
# REF: https://linuxconfig.org/how-to-create-a-backup-with-proxmox-backup-client

export PBS_REPOSITORY=10.9.1.23:zpbs1

date
time proxmox-backup-client backup \
 --include-dev /boot/efi \
 --include-dev /etc/pve \
 root-$(hostname).pxar:/ \
 --repository 10.9.1.23:zpbs1 # <pbs-ip-addr>:<pbs-datastore>

date

exit;

# root.pxar is name of bkp, / is root dir

# REF: https://pbs.proxmox.com/docs/backup-client.html

RESTORE:
Live-restore: This feature can allow you to start a VM when the restore job is started, rather than waiting for it to finish.

## proxmox-backup-client snapshot list

# proxmox-backup-client snapshot list --repository 10.9.1.23:zpbs1

# proxmox-backup-client restore host/elsa/2019-12-03T09:35:01Z root.pxar /target/path/
# proxmox-backup-client restore --repository 192.168.122.72:datastore0 host/doc-standardpcq35ich92009/2024-01-11T11:01:49Z etc.pxar /etc
