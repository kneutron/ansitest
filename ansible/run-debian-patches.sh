#!/bin/bash

ansible-playbook updt-debian.yaml 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit zfs-samba.lan
#						^ single server
