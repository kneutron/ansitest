#!/bin/bash

# for suse, may also work on rhel-derived
# Fix missing zfs shares in samba config
# 2023.Nov kneutron

conf=/etc/samba/smb.conf
cp -v $conf /etc/samba/smb.conf.bak-$(date +%Y%m%d)'@'$(date +%H%M)

template="
# boojumfix
[SHARENAME]
   path = REPLACEME
   writable = yes
   guest ok = yes
   guest only = no
   create mode = 0777
   directory mode = 0777

"

tmpfile=/tmp/fixsmb.tmp.txt
>$tmpfile

mods=0
for zd in $(zfs get sharesmb |awk '$3=="on" {print $1}'); do
  [ "$zd" = "" ] && break;
  
  mtpt=$(df |grep "$zd" |awk '{print $6}')  
  echo "$zd = $mtpt"
  
#set -x
# only if not already in smb.conf
  if [ $(grep -c $mtpt $conf) -lt 1 ]; then
    echo "$template" >$tmpfile

    dasher=$(echo $zd |tr '/' '-')
    
    sed -i 's|SHARENAME|'$dasher'|g' $tmpfile
    sed -i 's|REPLACEME|'$mtpt'|' $tmpfile
    cat $tmpfile >> $conf

    let mods=$mods+1
  fi
done

cat $conf
ls -l $conf
echo "Modified $mods shares"

if [ $mods -gt 0 ]; then 
  msg="$(date) - $0 - Restarting samba service" 
  logger $msg
  echo "$msg"
  systemctl restart smb
fi

zfs-show-my-shares.sh
