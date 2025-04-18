#!/bin/bash

echo "RUN THIS INSIDE LXC DEBIAN"

ln -sfn /usr/share/zoneinfo/America/Denver /etc/localtime 
dpkg-reconfigure tzdata

date

# REF: https://search.brave.com/search?q=proxmox+timezone+for+lxc&source=desktop&summary=1&conversation=42624bda795fa20034cd71
