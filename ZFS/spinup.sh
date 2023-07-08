#!/bin/bash

# spin up drives faster ?
# http://www.admin-magazine.com/HPC/Articles/GNU-Parallel-Multicore-at-the-Command-Line-with-GNU-Parallel
# http://www.gnu.org/software/parallel/parallel_tutorial.html#Building-the-command-line

logger "BOOJUM note - spinning up disks $0"
logfile=~/spinup.log

echo "`date` - boojum spinup called - spinning up disks" >> $logfile

infile=/run/shm/paratmp.list
> $infile # clearit

# exec to use
para=/usr/bin/parallel

# populate list of drives - REF: http://unix.stackexchange.com/questions/132126/which-command-to-force-a-drive-to-spin-up
# TODO random seek - 1-100 RND
# random REF: https://stackoverflow.com/questions/8988824/generating-random-number-between-1-and-10-in-bash-shell-script
for c in /dev/sd?; do 
  myrand=$(( ( RANDOM % 100 )  + 1 ))
  mycmd="echo $c;/bin/dd if=$c of=/dev/null bs=4096 skip=$myrand  count=1 iflag=direct" 
  echo "$mycmd" >> $infile
#  `$mycmd &`
done
 
#jobs
#limitt=6
limitt=5

#cat $infile |$para -j $limitt --progress --keep-order --group --linebuffer --results $paradir  qpbatch 
#cat $infile |$para -j $limitt --progress fdisk -l $1 
#|grep Disk

date1=`date +%s` # seconds
time cat $infile |$para  -j $limitt --progress 
wait;
date2=`date +%s` # seconds
let date3=$date2-$date1
echo "`date` + spinup took ($date3) seconds" >> $logfile

#/bin/dd if=$1 of=/dev/null bs=4096 count=1 iflag=direct 

# combine lines of output for brevity
# REF: https://stackoverflow.com/questions/9605232/how-to-merge-every-two-lines-into-one-from-the-command-line
#/root/bin/hd-power-status |awk 'NR%2{printf "%s ",$0;next;}1' 
/root/bin/hd-power-status 

#echo 'o DONE: '`date` #>> ~/$outlog

exit;

