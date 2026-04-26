#!/bin/bash

# safely remove a directory / subtree
# TODO EDITME
echo "RUN WITH CAUTION"

exit;

# all = all servers in inventory, change to limit to rhel9 / etc
ansible all -m file -a "dest=/tmp/deleteme state=absent" 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log
