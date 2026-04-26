#!/bin/bash

# group as defined in etc/ansible/hosts
ansible-playbook updt-debian.yaml --limit proxmox-lxc 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit zfs-samba.lan
#						^ single server
