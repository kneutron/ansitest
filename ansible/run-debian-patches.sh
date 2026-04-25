#!/bin/bash

ansible-playbook updt-debian.yaml

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit zfs-samba.lan
#						^ single server
