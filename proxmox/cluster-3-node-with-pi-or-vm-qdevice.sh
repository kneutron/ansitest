#!/bin/bash

# REF: https://www.youtube.com/watch?v=jAlzBm40onc
# This is when you really only have 2 nodes but need a 3rd vote for quorum
# Can setup debian vm with 512MB RAM OUTSIDE the cluster

# NOTE do not mix CPU types on host - all AMD or all Intel are OK

# do on all nodes in cluster
apt update
apt install -y corosync-qdevice

# TODO EDITME
pvecm qdevice setup 192.168.1.12 # vm on macpro, static ip

pvecm status
