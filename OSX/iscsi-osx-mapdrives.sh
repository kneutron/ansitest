#!/bin/bash

firstrun=0
# REQUIRES: https://github.com/iscsi-osx/iSCSIInitiator , XCODE

# REF: https://github.com/iscsi-osx/iSCSIInitiator/wiki/Target-Discovery
# REF: https://github.com/iscsi-osx/iSCSIInitiator/wiki/Authentication

# NOTE use  iscsi-osx-list-luns.sh  1st
#iscsictl add target iqn.2015-01.com.example:target,192.168.1.100:3260 -interface en0
iscsictl add target iqn.2021-07.example.com:lun1,10.9.7.12:3260 -interface en0
# dellap lmde

iscsictl list targets

if [ $firstrun -gt 0 ]; then
  iscsictl modify initiator-config -CHAP-name iscsi-user
  iscsictl modify initiator-config -CHAP-secret
# ^ Will prompt for password - should only need to do once

  iscsictl modify initiator-config -authentication CHAP
fi

if [ "$1" = "unmap" ]; then
# NOTE all zpools must be exported and indiv drives unmounted 1st
  iscsictl logout iqn.2021-07.example.com:lun1,10.9.7.12
  exit $? # early
fi

iscsictl login iqn.2021-07.example.com:lun1,10.9.7.12:3260 \
  -authentication CHAP \
  -CHAP-name iscsi-user \
  -CHAP-secret 
# password

echo PK
read -n 1

diskutil list |less
