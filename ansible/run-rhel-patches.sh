#!/bin/bash

echo "Make sure /etc/ansible/hosts is up to date"
ansible-playbook updt-rhel.yaml

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit rhel9-xrdp.ho
#                                               ^ single server
