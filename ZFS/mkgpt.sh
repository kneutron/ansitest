#!/bin/bash

argg=$1

source ~/bin/failexit.mrg

smartctl -a /dev/$argg |head -n 16
fdisk -l /dev/$argg

ls -l /dev/disk/by-id|grep $argg

echo "THIS WILL DESTRUCTIVELY APPLY A GPT LABEL - ARE YOU SURE - PK OR ^C"
read

parted -s /dev/$argg mklabel gpt || failexit 99 "! Failed to apply GPT label to /dev/$argg"

fdisk -l /dev/$argg
