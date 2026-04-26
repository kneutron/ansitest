#!/bin/bash

# This is for RHEL instances

# all = hit all known / reachable servers
# -m = use module name
# -a = module args
ansible all --become -m dnf -a "name=chrony state=present" 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log
# install pkg

ansible all --become -m service -a "name=chronyd state=started enabled=yes"
# systemctl enable --now chronyd
