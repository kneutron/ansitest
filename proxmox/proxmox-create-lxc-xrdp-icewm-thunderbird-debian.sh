#!/bin/bash

# 2024.Dec kneutron

# Goal: create a light-resources proxmox LXC container with thunderbird
#   that can be accessed with e.g. rdesktop or ' mstsc ' (Windows) from any PC in the house

# NOTE you can always give the LXC more RAM / Disk size in the PVE GUI later on if your mailbox is large

echo "This is script 1 of 2"
echo "Matching deploy script is here:"
echo " https://github.com/kneutron/ansitest/blob/master/proxmox/proxmox-deploy-lxc-debian-icewm-thunderbird.sh "
echo ''
echo '- YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT -'
echo '...the defaults may/not work for your environment'
echo ''

# xxx TODO EDITME
usestorage="local-lvm" # lvm-thin
disksize=10 # GB
numcpu=1
ramalloc=2 # GB
let vram=$ramalloc*1024

usedns=192.168.1.1
lxcpass="54321"


########################## No edits are needed past this point


# /var/lib/vz/template/cache/debian-12-standard_12.2-1_amd64.tar.zst
# NOTE this template needs to be downloaded beforehand on the proxmox host!!

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

template="/var/lib/vz/template/cache/debian-12-standard_12.2-1_amd64.tar.zst"
[ -e "$template" ] || failexit 44 "Debian template not found! Please download it on the proxmox host first"

echo "$(date) - Please wait, getting next free vmid"
let newid=$(pvesh get /cluster/nextid)
date

echo "About to create LXC: $newid using Debian image, for xrdp / rdesktop Thunderbird email" 
echo "The (lightweight) desktop environment will be: icewm, but you also have the choice"
echo "  of installing e.g. fluxbox , enlightenment , xfce4 , openbox , lxQT , windowmaker"
echo "  AfterStep, FVWM, Sawfish, JWM, tinywm, or whatever floats your boat."
echo ''
echo "Backing Storage: $usestorage -- Disk size: $disksize GB -- vCPU: $numcpu -- vRAM: $ramalloc GB" 
echo "Enter to proceed or ^C to stop"
read -n 1

# set cmode back to "tty" if you want to have a console login prompt, but sometimes it doesnt come up
(set -x
time pct create $newid \
  "$template" \
  --cmode shell \
  --cores $numcpu \
  --features nesting=1 \
  --hostname "debian-lxc-xrdp-thunderbird" \
  --memory $vram \
  --swap 512 \
  --nameserver $usedns \
  --net0 name="eth0",bridge="vmbr0",firewall=0,ip=dhcp,ip6=auto,link_down=0 \
  --ostype=debian \
  --password "$lxcpass" \
  --storage $usestorage \
  --rootfs volume=$usestorage:${disksize},mountoptions=noatime,size=${disksize}G \
  --unprivileged 1 \
  --start 1 \
  --timezone host \
  --description "Kneutron Debian LXC container for xrdp / rdesktop Thunderbird email" || failexit 99 "Failed to create LXC!"
)

#####################################################################################
date
echo "New VMID is $newid"
echo "  go to PVE dashboard on port 8006, select the new LXC / Console,"
echo "  you should have a root login prompt: \#"
echo ''
echo "NOTE root password = $lxcpass"
echo ''
echo "If you do not get a dhcp ip address, Disconnect the eth0 in the PVE GUI"
echo "  and Reconnect it"
echo "Then in-LXC, issue ' killall dhclient; dhclient -v eth0 ' without the quotes"
echo "  After that, ' ip a ' should return an IP address and you should be able to"
echo "  ping e.g. google.com - otherwise you may need to adapt LXC to your network"
echo ''
echo 'To (fairly easily) get the deploy script into the LXC:'
echo ''
echo "In-lxc as root, issue ' ip a; nc -l -p 80 |tar xpvf - ' "
echo ''
echo "Then on proxmox host (or wherever you have the deploy script downloaded) issue:"
echo " ' tar cpf - proxmox-deploy\*sh |nc -w 3 put-ip-address-of-lxc-here 80 '"
echo ''
echo "This should tar up the deploy script on the fly, and pass it to LXC with netcat"
echo "  without having to get involved with adding users and such."
echo ''
echo "Should work fine with Linux, if you are on Windows then will probably need to"
echo "  add a user, install / enable openssh_server, and use e.g. WinSCP"
echo '' 
echo "NOTE you may need to ' chmod +x ' the deploy script before running it."
echo ''
echo "Enjoy! Kneutron"

# REF: https://forum.proxmox.com/threads/how-to-create-a-container-from-command-line-pct-create.107304/

# Inspired by:
# REF: https://www.reddit.com/r/Proxmox/comments/1hayp1j/mail_client_vm/

# NOTE if no killall command, ' ps ax |grep dh ' and kill the PID of dhclient, then issue dhclient -v...
