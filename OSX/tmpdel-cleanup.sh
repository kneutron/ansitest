#!/bin/bash5

# mod for osx - clean out backup files in bin
# REQUIRES: gfind from ports/brew, bash 5.x

PATH=/opt/local/bin:/opt/local/sbin:/Users/dave/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/Users/dave/Library/Python/3.8/bin

keepdays=15

cd $HOME/tmpdel || mkdir -pv $HOME/tmpdel
cd $HOME/tmpdel || exit 99;

logf=$HOME/tmpdel-cleanup.log

# auto log rotate 1st of month
chkdate=$(date |awk '{print $3}')
[ "$chkdate" = "1" ] && mv -f $logf $logf--old


echo "CLEAN $(date)" >> $logf

mv -f $HOME/bin/*~ $HOME/tmpdel

chkid=$(id |awk '{print $1}')
if [ "chkid" = "uid=0(root)" ]; then
  mv -f $HOME/bin/boojum/*~ $HOME/tmpdel
fi

# in tmpdel
gfind . -name '*~' -mtime +$keepdays -print -delete >> $logf


#crontab
# Every day at 11pm clean out tmpdel *~ files older than 30 days
#0       23      *       *       *       /Users/dave/bin/tmpdel-cleanup.sh
