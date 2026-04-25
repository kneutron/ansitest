#!/bin/bash

# provide pass non-interactively to ssh-copy-id to setup instance for ansible control/access

# xxx TODO EDITME
export SSHPASS="87612345"
sshid=dave

# xxx TODO EDITME
#for SERVER in server1 server2; do
#for SERVER in "$@"; do

# all known hosts
for SERVER in $(egrep -v '^#|^\[' /etc/ansible/hosts |awk 'NF>0 {print $1}'); do
  echo "o Processing $SERVER"
  sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $sshid@$SERVER
  scp ansible-takeover-instance.sh $sshid@$SERVER:
done   

# if scp notwork, could ssh -cmd wget http + 1-liner server
