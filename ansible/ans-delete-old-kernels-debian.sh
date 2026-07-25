#!/bin/bash

ansible debian -m shell -a "apt -y autopurge; df -hT /" --become
echo '-----'
ansible pbs -m shell -a "apt -y autopurge; df -hT /" --become
echo '====='
date
