#!/bin/bash

ls Oracle_VM_VirtualBox_Extension*

if [ "$1" = "" ]; then
  echo 'o Enter which one to install'
  read instme
else
  instme="$1"
fi

VBoxManage extpack install --replace "$instme" # [--accept-license=sha256] <tarball>