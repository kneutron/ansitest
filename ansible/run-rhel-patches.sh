#!/bin/bash

# this does not need root
runonce=0
if [ $runonce -gt 0 ]; then
  ansible-galaxy collection install community.proxmox
  pip install proxmoxer requests
fi

mydt=$(date +%Y%m%d@%H%M_%S)

# NOTE RHEL instances dont need powered on 24/7, just for patching - all are currently on beelink
# use API to power on if needed
ansible-playbook -vv poweron-rhel.yaml 2>&1 |tee /var/log/ansible/$(basename $0)-${mydt}.log

date
#exit # early


echo "Make sure /etc/ansible/hosts is up to date"
if [ "$1" = "" ]; then
  ansible-playbook -vv updt-rhel.yaml 2>&1 |tee -a /var/log/ansible/$(basename $0)-${mydt}.log
else
  ansible-playbook -vv updt-rhel.yaml --limit "$@" 2>&1 |tee -a /var/log/ansible/$(basename $0)-limited-${mydt}.log
fi

date

# HOWTO Rerun a failed job:
# ansible-playbook updt-debian.yaml --limit rhel9-xrdp.ho
#                                               ^ single server

# ========

# To power on a Proxmox instance if it is currently off, use the
# community.proxmox.proxmox_kvm module (for virtual machines) or
# community.proxmox.proxmox     module (for LXC containers) 
# and set the state parameter to started

#Collection: Make sure you have the dedicated collection installed via:
# ansible-galaxy collection install community.proxmox

# Local Dependencies: The machine running this Ansible task
#(usually your local control machine, hosts: localhost) requires the
# proxmoxer and requests  Python libraries installed.

# PROTIP for yaml api:
# an api token cannot have more permissions than the user!

# Datacenter / Permissions / Roles - create startstopvms with "datastore.audit vm.audit vm.powermgmt "
# Datacenter / Permissions / Users - create startstopinstance
# Datacenter / Permissions / api tokens - create startstopinstance@pam - tokenid: blah - uncheck priv sep

# Datacenter / Permissions - add User permission "/" with startstopinstance@pam, Role = startstopvms
# Datacenter / Permissions - add API token perm "/storage" with startstopinstance@pam!blah, Role = pvedatastoreadmin
# Datacenter / Permissions - add API token perm "/vms" with startstopinstance@pam!blah, Role = startstopvms
