#!/bin/bash

# REF: https://github.com/openzfs/zfs/issues/9935
# Fix compile issues on Debian

# arg1=kernel ver e.g. 4.19.9
cd /usr/src/linux-headers-$1-common/include/linux
td=$PWD; [ "$td" = "" ] && exit 404;

cd /usr/src/linux-headers-$1-amd64/include && \
  ln -sfn $td . 

ls -alh
