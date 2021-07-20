#!/bin/bash

# REQUIRES: https://github.com/sahlberg/libiscsi

ip=10.9.7.12 # dellap lmde, iscsi host/target

iscsi-ls iscsi://$ip
iscsi-ls -s iscsi://iscsi-user%password@$ip
#iscsi-ls -s iscsi://@$ip
