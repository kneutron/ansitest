#!/bin/bash

cat /proc/mdstat
echo '====='
mdadm --detail /dev/md0
date
