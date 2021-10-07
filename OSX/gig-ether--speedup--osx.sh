#!/bin/bash

# http://fasterdata.es.net/host-tuning/linux/

# REF: https://www.atto.com/software/files/other/osx_fastframe_readme_v7_20.pdf

# REF: https://hints.macworld.com/article.php?story=20060616112919669 ## OLD
#  If you would like these changes to be preserved across reboots you can edit /etc/sysctl.conf.
# 

sysctl -w kern.ipc.maxsockbuf=4194304 
# will not go higher in OSX due to system limitations.

sysctl -w net.inet.tcp.sendspace=2097152
sysctl -w net.inet.tcp.recvspace=2097152
sysctl -w net.inet.tcp.maxseg_unacked=32
sysctl -w net.inet.tcp.delayed_ack=2
sysctl -w kern.maxnbuf=60000
sysctl -w kern.maxvnodes=280000
sysctl -w net.inet.tcp.sack=1


# determine interfaces found OTF xxx 2017.0319
#for e in `ifconfig -a |grep HW |awk '{print $1}'`; do
#  ifconfig $e txqueuelen 5000
#ifconfig eth1 txqueuelen 5000
#done

#http://datatag.web.cern.ch/datatag/howto/tcp.html
#sysctl sys.net.core.netdev_max_backlog=2000 # unknown
##sysctl net.ipv4.tcp_sack=0 

ifconfig -a > /var/root/ifconfig-a.txt
chmod 500 /var/root/ifconfig-a.txt

exit;

 ifconfig en0  mediaopt full-duplex
[ davesimac513.local (scrn=1) ]

# ifconfig en0
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        options=10b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV>
        ether 3c:07:54:64:eb:10
        inet6 fe80::4f2:bbae:d379:1882%en0 prefixlen 64 secured scopeid 0x6
        inet 10.9.13.4 netmask 0xff000000 broadcast 10.255.255.255
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect (1000baseT <full-duplex,flow-control,energy-efficient-ethernet>)
        status: active
