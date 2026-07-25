#!/bin/bash

cmd="date"
#ansible rhel8 -a "$cmd"
#echo '-----'
for stanza in $(grep "^\[" /etc/ansible/hosts |grep -v vars); do
#ansible rhel -a "$cmd"
 echo $stanza
 st2=$(echo "$stanza" |tr -d '[]')
 ansible $st2 -a "$cmd"
 echo "^^ $st2 -----"
#ansible debian -a "$cmd"
#echo '-----'
#ansible pbs -a "$cmd"
 echo '-----'
done

date;
