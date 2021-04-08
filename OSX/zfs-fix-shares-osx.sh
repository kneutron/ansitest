#!/bin/bash

function fixman () {
for share in `zfs-show-my-shares--osx.sh |grep 'sharesmb  on' |awk '{print $1}'`; do
  echo "Fixing $share"
  zfs set sharesmb=on $share
done
}

# 2019.0924 try this instead
zfs share -a
fixman

#zmac320/sharecompr-320int                             sharesmb  on        local
#zredteraB/shrcompr-zrtB                               sharesmb  on        local

zfs-show-my-shares--osx.sh
