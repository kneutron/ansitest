#!/bin/bash

# REF: https://blog.jasonantman.com/2012/04/adjusting-the-virtualbox-f12-bios-boot-prompt-timeout/

VBoxManage list vms

vmname="$1"
VBoxManage modifyvm "$vmname" --bioslogodisplaytime 10000
