#!/bin/bash

echo "RUN WITH CAUTION"

exit;

# replace rhel9 with server group
ansible rhel9 -i /etc/ansible/hosts -a "/sbin/reboot" --become

date

