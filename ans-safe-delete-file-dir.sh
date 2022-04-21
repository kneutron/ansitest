#!/bin/bash

# Safely delete file or directory tree with ansible
# Author takes NO responsibility for accidents or misuse, USE AT YOUR OWN RISK

# arg1=server(s), comma-separated
# arg2=path/to/file

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Basic sanity
[ "$1" = "" ] && failexit 404 "Server(s) not specified as arg 1"
[ "$2" = "" ] && failexit 405 "File / Dir not specified as arg 2"

# "" should catch root
for crit in "" bin boot dev etc home lib media mnt opt proc root root/bin run sbin srv sys tmp usr usr/bin usr/sbin var; 
do
  if [ "$2" = "/$crit" ] || [ "$2" = "/$crit/" ]; then 
    failexit 999 "ARE YOU INSANE? NO! ( ︶︿︶)_╭∩╮"
  fi
done

echo "Processing servers: $1"
time ansible $1 -m file -a "dest=$2 state=absent" --become

exit;

Example usage - On target server:

# mkdir -pv /tmp/complexdir
# cd /tmp/complexdir && \
# for d in {1..50}; do mkdir -pv $d/$d; done

# $0 targetserver /tmp/complexdir # the whole directory tree should be GONE from /tmp after running this script
