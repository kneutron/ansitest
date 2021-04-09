#!/bin/bash

# NOTE osx does not seem to have a concept of wwn anywhere that I can find (smartctl, diskutil, dev/*)

DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

ls -l $DBI $DBP $DBS |egrep -v 'var/|s[0-9]|total' |column -t |sort -k 11 |awk '{ print $11" "$10" "$9 }'

diskutil list |grep -A 2 physical
