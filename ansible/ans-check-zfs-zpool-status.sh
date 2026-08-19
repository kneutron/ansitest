#!/bin/bash

# 2026.Aug kneutron

# runs from cron daily 7am and 7pm - check known zpools for error conditions and gotify if needs manual check

PATH=/home/dave/bin:/home/dave/ansible/default:/home/dave/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ofile=/dev/shm/zpool-status-ansible.log
[ -e $ofile ] && /bin/mv -v $ofile ${ofile}.old
touch $ofile; chmod 755 $ofile

# display timestamp w date, skip blank lines
cmd="zpool status -Tdv |awk 'NF>0'; echo ''; zpool status -x; echo '-------------------------------'"

ansible has_zfs -m shell -a "$cmd" \
 |tee $ofile

(echo '========'
date;) |tee -a $ofile

[ $(egrep -c 'DEGRADED|FAULTED|UNAVAIL|REMOVED|Permanent' $ofile) -gt 0 ] && \
  gotifytest-general.sh "Check zpool status $ofile -- error condition detected" 

ls -lh $ofile

#Wed Aug 19 03:14:02 PM MDT 2026
#-------------------------------
