#!/bin/bash

# NOTWORK
#ansible all -i /etc/ansible/hosts -m setup -a 'filter=ansible_*_macaddress'
#ansible all -i /etc/ansible/hosts -m setup -a 'filter=ansible_default_ipv4.macaddress'
#ansible all -i /etc/ansible/hosts -m command -a 'cat /sys/class/net/*/address'

ansible all -i /etc/ansible/hosts -m shell -a 'cat /sys/class/net/*/address'
