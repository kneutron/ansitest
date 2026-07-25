#!/bin/bash

# 2026.May kneutron
# simple add newhostname under existing stanza in main hosts file, edit afterward if needs IP, etc
# maybe use with takeover script

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

myfile=/etc/ansible/hosts

echo "o Usage: arg1 = existing stanza to add newhost under; arg2 = newhostname"
echo "NOTE - new instances are added to the TOP of the stanza stack, not the bottom!"
echo '====='
echo "Available stanzas:"
grep "^\[" $myfile
echo '====='

stanza=$1
[ "$stanza" = "" ] && failexit 44 "Arg1 stanza must not be blank!"
[ $(grep -c "^\[$stanza\]" $myfile) -gt 0 ] || failexit 45 "Arg1 stanza specified is not found in $myfile!"
# needs to match exact text or will add to EOF

nhn=$2 
[ "$nhn" = "" ] && failexit 46 "Arg2 newhostname must not be blank!"
# TODO add ping test?

#ansible-playbook add-instance-to-ansible-hosts.yaml --become -e "stanza=$stanza newhostname=$nhn" 2>&1 \
ansible-playbook add-instance-to-ansible-hosts.yaml --become --extra-vars "stanza=$stanza newhostname=$nhn" 2>&1 \
 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M_%S).log

ls -lh $myfile
grep -c "$nhn" $myfile
# If >0, was successfully added

if [ -e ~/.ssh/id_rsa ]; then
: # noop
else
  echo "o Generating local ssh keys" # no prompts
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N "" -q
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q   
  ls -l ~/.ssh/*
fi

me=$(whoami) 

echo "o Enter your password for $me@$nhn when prompted"
ssh-copy-id $me@$nhn

echo "o Copying takeover script to $nhn"
#scp ~/ansible/ansible-takeover-instance.sh $me@$nhn:
scp ~/ansible/default/ansible-takeover-instance.sh $me@$nhn:

echo "o Executing ansible takeover script on $nhn"
ssh $me@$nhn "chmod +x *sh; sudo -S ./ansible-takeover-instance.sh"

date;
