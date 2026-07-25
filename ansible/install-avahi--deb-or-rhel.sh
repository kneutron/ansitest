#!/bin/bash

# run as root

if [ $(which apt-get |wc -l) -gt 0 ]; then
# debian-derived
 apt update
 apt-get install -y avahi-discover avahi-ui-utils avahi-utils mdns-scan sudo
 usermod -aG sudo avac_admin

elif [ $(which dnf |wc -l) -gt 0 ] || [ $(which yum |wc -l) -gt 0 ]; then
# rhel-derived
 dnf install -y avahi avahi-ui-gtk avahi-tools mdns-scan nss-mdns sudo
 usermod -aG wheel avac_admin

else
 echo "ERROR: Unknown distro type, this script only works on debian-derived and rhel-derived"
 exit 44;
fi
