#!/bin/bash

# arg1=kernel ver
cd /usr/src/linux-headers-$1-common/include/linux
td=$PWD

cd /usr/src/linux-headers-$1-amd64/include
ln -sfn $td . 

ls -alh
