#!/bin/bash

# provide pass non-interactively to ssh-copy-id to setup instance for ansible control/access

# xxx TODO EDITME
export SSHPASS="87654321"

# xxx TODO EDITME
for SERVER in server1 server2; do
  sshpass -e ssh-copy-id -o StrictHostKeyChecking=no ansibleuser@$SERVER
done   
