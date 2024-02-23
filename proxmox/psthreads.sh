#!/bin/bash

# show threads and grep for thing
# example usage: $0 zstd
# $0 vmid

ps -eLf |head -n 1
ps -eLf --columns $COLUMNS |grep "$@" |egrep -v 'grep|bash'

