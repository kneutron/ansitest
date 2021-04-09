#!/bin/bash

DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

# 2019.0430 by-path is kinda useless, but re-enable if needed
#ls -lR $DBI $DBP $DBS |grep $1
ls -lR $DBI $DBS |grep $1 |awk '{ print $11" "$10" "$9 }' |column -t

