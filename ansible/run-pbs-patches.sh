#!/bin/bash

if [ "$1" = "" ]; then
  ansible-playbook -vv updt-pbs.yaml 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M_%S).log
else
  ansible-playbook -vv updt-pbs.yaml --limit "$@" 2>&1 |tee /var/log/ansible/$(basename $0)-limited-$(date +%Y%m%d@%H%M_%S).log
fi

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit zfs-samba.lan
#						^ single server
