#!/bin/bash

ansible-galaxy collection install community.general   

ddir=/var/log/ansible/hosts
[ -e "$ddir" ] || mkdir -pv $ddir

chown $(whoami) $ddir

echo "Log Files will live in /var/log/ansible/hosts"
echo '' 
echo "Enable this in ansible.cfg:"
echo "[defaults]
callback_whitelist = log_plays"
