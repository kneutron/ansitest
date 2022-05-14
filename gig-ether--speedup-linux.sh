#!/bin/bash

# http://fasterdata.es.net/host-tuning/linux/

# increase TCP max buffer size setable using setsockopt()
# 16 MB with a few parallel streams is recommended for most 10G paths
# 32 MB might be needed for some very long end-to-end 10G or 40G paths
sysctl net.core.rmem_max=16777216 
sysctl net.core.wmem_max=16777216 
# increase Linux autotuning TCP buffer limits 
# min, default, and max number of bytes to use
# (only change the 3rd value, and make it 16 MB or more)
sysctl net.ipv4.tcp_rmem="4096 87380 16777216"
sysctl net.ipv4.tcp_wmem="4096 65536 16777216"
# recommended to increase this for 10G NICS
sysctl net.core.netdev_max_backlog=30000
# these should be the default, but just to be sure
sysctl net.ipv4.tcp_timestamps=1

# 1 to 0 per:
# 
sysctl net.ipv4.tcp_sack=0


sysctl net.core.wmem_max=8388608
#sysctl net.core.wmem_default=65536
#sysctl net.core.rmem_default=65536
sysctl net.core.wmem_default=131072
sysctl net.core.rmem_default=131072
sysctl net.ipv4.tcp_window_scaling=1
sysctl net.ipv4.tcp_mem='98304 131072 196608'

# determine interfaces found OTF xxx 2017.0319
#for e in `ifconfig -a |grep flags |awk '{print $1}'`; do
# fix for cubietruck 2019
for e in `ifconfig -a |grep flags |awk -F: '{print $1}'`; do
  ifconfig $e txqueuelen 5000
#ifconfig eth1 txqueuelen 5000
done

ifconfig -a > /root/ifconfig-a.txt
ip a >> /root/ifconfig-a.txt
chmod 500 /root/ifconfig-a.txt

# use faster usb wireless if connected
#fwifi=`lsmod |grep -c rt2800usb`
#[ "$fwifi" -gt 0 ] && /root/bin/boojum/wireless-commandline.sh &

#http://datatag.web.cern.ch/datatag/howto/tcp.html
#sysctl sys.net.core.netdev_max_backlog=2000 # unknown
##sysctl net.ipv4.tcp_sack=0 

