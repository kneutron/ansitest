#!/bin/bash

# group as defined in etc/ansible/hosts
ansible-playbook updt-debian.yaml --limit proxmox-lxc

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit zfs-samba.lan
#						^ single server
