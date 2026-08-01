#!/bin/bash

# 2026.Aug kneutron

# Ex. $0 debian-xrdp-email debian-10gbit-net-browser.local

echo "
! USE WITH CAUTION - this action is logged !
o NOTE - rsyslog also captures this remotely for forensic purposes
"

# Instance must be in /etc/ansible/hosts and have already run the takeover script on it
# (and be powered on)

myhn=$(hostname -s)
myid=$(id -un)

logf=/var/log/ansible/halted-by-ansible.log

vms="$@" # arg(s) passed

echo "
NOTE - a red error after this does -not- mean it did not work!"

logger "$(date) - ANSIBLE - Powered off by $myid@$myhn: $vms" # rsyslog record
echo "$(date) - Powered off by $myid@$myhn: $vms" |tee -a $logf

ansible "$vms" -m shell --become -a "echo $(date) - Powered off with ansible by $myid@$myhn >>/root/ansible-halt.log; halt -p" 
date

ls -lh $logf
