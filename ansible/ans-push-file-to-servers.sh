#!/bin/bash

# TODO EDITME
ansible all -m copy -a "src=/etc/chrony.conf dest=/home/dave" 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log
