#!/bin/bash

# open top on vt9
setterm -blank 0 2>/dev/null

usepg=open
[ -e `which openvt` ] && usepg=openvt

( TERM=linux $usepg -f -c 9 -s -w -- /usr/bin/top -d 15 ) &
