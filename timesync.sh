#!/bin/bash

# mod for rhel8 / alma
# REF: https://access.redhat.com/solutions/4130881

date
# if exist, use it
[ $(type -path ntpdate |wc -l) -gt 0 ] && ntpdate -s pool.ntp.org

# RHEL8 / alma

if [ $(systemctl -a |grep chronyd |head -n 1 |wc -l) -gt 0 ]; then
  systemctl stop chronyd
  chronyd -q
  systemctl start chronyd
fi

date

#ntp1.linuxmedialabs.com
# pool.ntp.org
# ntp1.tummy.com - CO
# louie.udel.edu - DElwr
# ntp.shorty.com - GA

# inetd's timeserver is port 37; use ' rdate servername '
