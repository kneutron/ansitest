#!/bin/bash

vmid="$1"
phase="$2"
vmconf="/etc/pve/qemu-server/$vmid.conf"

if [[ "$phase" == "post-start" ]]; then
    # waiting for vm guest service to start
    started="false"
    loopstart=$EPOCHSECONDS
    while [[ "$started" == "false" ]]; do
        qm guest cmd $vmid ping && started="true"
        if [[ "$started" == "false" ]]; then
            sleep 2
        fi
        if (( EPOCHSECONDS-loopstart > 60 )); then
            echo "timeout for vm guest service start"
            break
        fi
    done

    # sync VM time after resume or start
    if [[ "$started" == "true" ]]; then
        if grep -q "ostype: win" $vmconf; then
            newdate=$(date +"%d-%m-%y")
            newtime=$(date +"%H:%M")
            echo "resync windows time"
            qm guest exec $vmid "cmd" "/c net stop W32Time & date $newdate & time $newtime & net start W32Time & w32tm /resync /nowait"
        else
            echo "resync linux time"
            echo '{"execute":"guest-set-time"}' | socat stdin unix-connect:"/var/run/qemu-server/$vmid".qga
        fi
    else
        echo "vm guest service not running"
        exit 1
    fi
fi
# REF: https://forum.proxmox.com/threads/windows-vm-time-not-updated-after-hibernate-resume.110517/page-2#post-624212
