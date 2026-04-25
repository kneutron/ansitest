#!/bin/bash

# safely remove a directory / subtree
# TODO EDITME
echo "RUN WITH CAUTION"

exit;

# all = all servers in inventory, change to limit to rhel9 / etc
ansible all -m file -a "dest=/tmp/deleteme state=absent"
