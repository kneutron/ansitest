#!/bin/bash

# only need passfile if dave is not in wheel/sudoers and nopasswd fix has not been run
cmd="grep tty /etc/sudoers"
ansible rhel8 --become -m command -a "$cmd" #--become-password-file=~/ansible/sudo_pass.txt
echo '-----'
ansible rhel9 --become -m command -a "$cmd" #--become-password-file=~/ansible/sudo_pass.txt
echo '-----'
ansible debian --become -m command -a "grep -c tty /etc/sudoers" #--become-password-file=~/ansible/sudo_pass.txt

date;
