#!/bin/bash

# 2026.Apr kneutron

# Run this as root on new debian // rhel/rocky/alma Linux instance to prep as ansible target for updates, etc
logf=~/$(basename $0).log
touch $logf

# if node=debian
result=$(grep -ic debian /etc/os-release)
if [ $result -gt 0 ]; then
  apt update
  apt install -y avahi-discover avahi-ui-utils avahi-utils mdns-scan 2>>$logf
  apt install -y joe mc screen tmux vim nano net-tools pigz sudo openssh-server 2>>$logf
fi


# if node=rhel
result=$(grep -E -ic 'rhel|fedora' /etc/os-release)
if [ $result -gt 0 ]; then
# no 'which' in default install
  [ $(type -a python3 |wc -l) -gt 0 ] || dnf install -y python3.12	# as of Apr 2026

  dnf config-manager --set-enabled crb
  dnf install -y epel-release
  crb enable
  
  result2=$(dnf repolist |grep -c epel)
  [ $result2 -gt 0 ] || echo "$(date) - ERROR - epel did not get installed on $(hostname)" |tee -a $logf  

  dnf install -y avahi avahi-tools mdns-scan nss-mdns 2>>$logf
  systemctl restart avahi-daemon
  
  dnf install -y joe mc screen tmux vim nano pigz openssh-server wget 2>>$logf
  systemctl restart sshd
fi


# TODO editme - default user
#myid=dave
if [ $((id $myid) 2>&1 |grep -c 'no such user') -gt 0 ]; then
 echo "o Creating $myid and setting password" |tee -a $logf
 useradd --create-home $myid
 echo -e '87654321\n87654321' |passwd $myid
 usermod -aG wheel $myid || usermod -aG sudo $myid
# wheel = rhel, sudo = debian
else
 echo "o $myid already exists" |tee -a $logf
fi
id $myid

[ -e /mnt/disc ] || mkdir -pv /mnt/disc


# final check for supported OS
result=$(grep -E -ic 'debian|rhel|fedora' /etc/os-release)
if [ $result -eq 0 ]; then
  echo "o Unknown target node type, must be debian or rhel/fedora-derived"
  exit 44;
fi

ls -lh $logf 

exit 0;


# To get this script on target instance:
# (in target)
# scp user@ansibleserverip:$0 . 	# if script is in /home/user
# scp user@ansibleserverip:/tmp/$0 . 	# if script is in /tmp and readable by user u=rx

# To serve this script on LAN with a 1-liner so node can download it with wget:
# pwd; ip a |grep 'inet '; python3 -m http.server 80	# use another port if already have http server on :80, hit ^C to stop server
#
# On target instance:
# wget http://ansibleip/$0

# To make a mountable ISO image with this script for VM:
# mkisofs -d -D -f -l -J -N -r -T -v -o ansible-takeover-script.iso  $0		# will make .iso in current dir
