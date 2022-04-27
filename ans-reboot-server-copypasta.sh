#!/bin/bash

# NOTE need bash >3.2.57 on OSX for this

# Paste a vertical list of servers separated by newline
# ^ pass them as comma-separated server(s) to ansible; reboot and wait up to 10 min

echo "Paste vertical list of servers / IP addresses; Enter EOF at the end of server list to begin processing"

buildstr=""
while read inline; do
  [ "$inline" = "EOF" ] && break;
  
  fstchr=${inline:0}
  if [[ $fstchr =~ ^[0-9] ]] && [ $(echo $inline |awk '{sum+=gsub(/\./,"")}END{print sum}') -eq 3 ]; then
# 1st char=number and contains 3 dots, more than likely an IPV4 addr
    buildstr="$buildstr$inline,"
  else
    hnonly=${inline%%.*} # strip evyting after first dot, dont need FQDN
    hnonly=${hnonly,,} # and lowercase it
    buildstr="$buildstr$hnonly,"
  fi
done
buildstr=$(echo ${buildstr%,}) # omit trailing comma

servers=$buildstr
echo "$buildstr"
ansible-playbook reboot-and-wait.yml --become -e "target=$servers"
