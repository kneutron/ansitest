#!/bin/bash

# mod for SUSE
zypper ref
zypper update

#debsort
#mv -f -v ~/DEBInstalled.list ~/DEBInstalled.list.prev ; \
#  dpkg -l >~/DEBInstalled.list 

rpmsortinst &

# only updt if locatedb >24H old
# REF: https://unix.stackexchange.com/questions/275728/set-ls-l-time-format
#ls -lhk --time-style='+%s' /var/lib/mlocate/mlocate.db
# 1	    2 3    4    5   6
#-rw-r--r-- 1 root root 21M 1665244188 /var/lib/mlocate/mlocate.db
# date +%s
#1665249077

now=$(date +%s)
dbage=$(ls -lhk --time-style='+%s' /var/lib/mlocate/mlocate.db |awk '{print $6}')
let timediff=$now-$dbage
if [ $timediff -ge 86400 ]; then
 updatedb &
else
 echo "NOTE Skipping updatedb, timediff is only $timediff"
fi
#squiderr
#efibootmgr
