#!/bin/bash

# REF: https://www.youtube.com/watch?v=xszkW9cnDC4
# for proxmox on laptop, do not suspend when screen down / lid closed

inf=/etc/systemd/logind.conf
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' $inf
grep -i lid $inf

systemctl restart systemd-logind
