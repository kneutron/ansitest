#!/bin/bash

ansible rhel8 -a "df -hT /"
echo '-----'
ansible rhel9 -a "df -hT /"
echo '-----'
ansible debian -a "df -hT /"


