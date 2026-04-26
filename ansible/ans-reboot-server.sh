#!/bin/bash

# pass comma-separated server(s) as arg; reboot and wait up to 10 min
if [ "$1" = "" ]; then
  echo "Provide at least one target server as parameter"
  exit 404;
else
  servers=${@%,} # omit trailing comma
  echo "$servers"
  ansible-playbook reboot-and-wait.yml --become -e "target=$servers" 2>&1 |tee /var/log/ansible/$(basename $0)-$(date +%Y%m%d@%H%M%S).log
  #--become-password-file=~/ansible/sudo_pass.txt
fi

exit;


# example output:
# bash multi-line comment block
: '
time ans-reboot-server.sh ubuntu-ntpserver; date
ubuntu-ntpserver

PLAY [ubuntu-ntpserver] *********************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************
ok: [ubuntu-ntpserver]

TASK [reboot and wait] **********************************************************************************************************************************
changed: [ubuntu-ntpserver]

TASK [check uptime] *************************************************************************************************************************************
changed: [ubuntu-ntpserver]

TASK [debug] ********************************************************************************************************************************************
ok: [ubuntu-ntpserver] => {
    "uptimeoutput.stdout_lines": [
        " 13:23:25 up 0 min,  2 users,  load average: 2.25, 0.49, 0.16"
    ]
}

PLAY RECAP **********************************************************************************************************************************************
ubuntu-ntpserver           : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

real    0m25.975s
'
