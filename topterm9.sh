#!/bin/bash

result=$(ps ax |awk '/tty9/ {print }' |grep -c top)

if [ $result -eq 0 ]; then
# open top on vt9
setterm -blank 0 2>/dev/null
( TERM=linux openvt -f -c 9 -w -- /usr/bin/top -d 15 ) &
else
  echo "WARNING topterm9 already running - skipping"
fi
 