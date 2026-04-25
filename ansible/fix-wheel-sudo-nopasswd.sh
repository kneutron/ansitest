#!/bin/bash

# This is rhel-specific

# make sure on all known hosts %wheel group can do sudo w/ nopass, for ansible control
# User dave also needs to be in wheel group (rhel) or sudo group (debian)

# Takes 1 arg, typically " rhel9 " or " rhel "
ansible-playbook ~/ansible/ans-fix-wheel-nopass.yml --become -e "target=$@" --become-password-file=~/ansible/sudo_pass.txt
