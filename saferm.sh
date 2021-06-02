#!/bin/bash

# safe delete with find and rm, logged
# 2019 Dave Bechtel

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# xxxxx TODO CHANGEME
dest=/mnt/tmp

logfile=~/safeRM.log
> $logfile # clearit

cd "$dest" || failexit 99 "! Unable to cd to $dest"

# xxxx TODO CHANGEME wildcard files
time find -P "$dest"/* -mount -name "*.wav" -type f -exec /bin/rm -v {} >> $logfile \;

ls -alh $logfile

exit;

REF: http://unix.stackexchange.com/questions/167823/find-exec-rm-vs-delete
