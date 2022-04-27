#!/bin/bash

# pass comma-separated server(s) as arg; reboot and wait up to 10 min
if [ "$1" = "" ]; then
  echo "Provide at least one target server as parameter"
  exit 404;
else
  servers=${@%,} # omit trailing comma
  echo "$servers"
  ansible-playbook reboot-and-wait.yml --become -e "target=$servers"
fi

