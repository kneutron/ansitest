#!/bin/bash

# Linux ps
ps ax -o pid,ppid,s,cmd |awk '$3 ~ /Z/'
# ^ Print pid, parent pid, State, commandline and only print if 3rd column matches Z = zombie

# kill -9 on the PARENT pid, should clear them up
