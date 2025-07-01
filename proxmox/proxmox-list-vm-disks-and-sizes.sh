#!/bin/bash

set -x
lsOutput=$(ls -lh /dev/disk/by-id/ | awk '{print $9 "\t" $11}' | sed '/part/d;s/\.\.\/\.\.\///g;/scsi/!d;/DVD/d' | sort -t $'\t' -k2b,2)
lsblkOutput=$(lsblk | sed '/^s/!d' | awk '{print $1"\t"$4}' | sort -t $'\t' -k1b,1b)
join -t $'\t' -1 2 -2 1 -o 1.1 1.2 2.2 <(echo "$lsOutput") <(echo "$lsblkOutput") | sort -V

# REF: https://forum.proxmox.com/threads/how-to-tell-which-disk-files-a-kvm-guest-is-using.26255/
