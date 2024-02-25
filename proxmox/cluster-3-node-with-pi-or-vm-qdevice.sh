#!/bin/bash

# REF: https://www.youtube.com/watch?v=jAlzBm40onc

# do on all nodes in cluster
apt update
apt install -y corosync-qdevice

pvecm qdevice setup 192.168.1.12 # vm on macpro, static ip

pvecm status
