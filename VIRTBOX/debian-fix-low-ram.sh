#!/bin/bash

# Unload modules + daemons for low RAM - debian/devuan
free -h

service apparmor stop
service bluetooth stop
service brltty stop
service cups stop
service cups-browsed stop
service exim4 stop
service gpm stop
service saned stop


modprobe -r bluetooth
modprobe -r parport_pc
modprobe -r ppdev
modprobe -r lp
modprobe -r parport
modprobe -r joydev
modprobe -r pcspkr
modprobe -r serio_raw

lsmod
(service --status-all 2>&1) |grep +

free -h