#!/bin/bash

# safe delete with find and rm, logged

source ~/bin/failexit.mrg

# xxxxx CHANGEME
dest=/mnt/tmp

logfile=~/safeRM.log
> $logfile # clearit

cd "$dest" || failexit 99 "! Unable to cd to $dest"

# xxxx CHANGEME wildcard files
time find -P "$dest"/* -mount -name "*.wav" -type f -exec /bin/rm -v {} >> $logfile \;

ls -alh $logfile

exit;

REF: http://unix.stackexchange.com/questions/167823/find-exec-rm-vs-delete
