#!/bin/bash

# This runs on the QEMU Host
# portfwd to squid on raspberry pi; run-qemu is listening for ssh on 32222
ssh -2 -C -Y -oTCPKeepAlive=yes -g -R 3128:10.1.0.4:3128 -l user localhost -p 32222
