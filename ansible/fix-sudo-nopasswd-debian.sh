#!/bin/bash

# make sure on all known hosts %wheel group can do sudo w/ nopass, for ansible control
# User dave also needs to be in wheel group (rhel) or sudo group (debian)

# takes 1 arg, typically " debian "
ansible-playbook ~/ansible/ans-fix-sudo-nopass-debian.yml --become -e "target=$@" --become-password-file=~/ansible/sudo_pass.txt
