#!/bin/bash

ansible all -i /etc/ansible/hosts -m setup -a " filter=*ipv4_addr* "
