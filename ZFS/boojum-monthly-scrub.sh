#!/bin/bash

# NOTE runs from /etc/crontab
# example for osx:
# # 12:01am 23rd-27th every month, run zfs scrub 1 day for 1 pool - TODO expand if more pools
#1  0  23  *  *  /var/root/bin/boojum/boojum-monthly-scrub.sh > /var/root/boojum-monthly-scrub.log 2>>/var/root/boojum-scrub-errs.log
#1  0  24  *  *  /var/root/bin/boojum/boojum-monthly-scrub.sh > /var/root/boojum-monthly-scrub.log 2>>/var/root/boojum-scrub-errs.log
#1  0  25  *  *  /var/root/bin/boojum/boojum-monthly-scrub.sh > /var/root/boojum-monthly-scrub.log 2>>/var/root/boojum-scrub-errs.log

# based on DOM 23/24/25, scrub 1 of N pools && wait4scrub to finish while logging progress
# NOTE tabwidth=2

PATH=/sbin:/root/bin:/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin: #/usr/NX/bin:/usr/games:

debugg=0

mydt=$(date +%e) # ex. 24

[ $debugg -gt 0 ] && mydt=27
# short circuit to smallest pool for testing (ztestpool4

 # zpool list # as of 2017.0319
# NAME         SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
# zseatera2   3.62T  1.64T  1.98T         -    22%    45%  1.00x  ONLINE  -
# zseatera4   3.62T  2.73T   913G         -    37%    75%  1.00x  ONLINE  -
# zsgtera2    1.81T  1.57T   248G         -    50%    86%  1.00x  ONLINE  -
# zteratank3  2.72T  2.00T   737G         -    29%    73%  1.00x  ONLINE  -
# ztestpool4  3.62T  1.30T  2.33T         -    20%    35%  1.00x  ONLINE  -
 
[ "$1" = ""  ] || mydt=$1 # override in case we missed 

logfile=~/boojum-monthly-scrub-$mydt.log # sep logfiles, by daynum
/bin/mv $logfile $logfile--prev

# zfs list -d0
#NAME         USED  AVAIL  REFER  MOUNTPOINT	
#teratank3   2.28T   363G  1.93T  /teratank3	#23
#zseatera2   1.83T  1.68T  2.98G  /zseatera2	#24
#zseatera4   2.55T   990G    96K  /zseatera4	#25
#zsgtera2    1.57T   190G   927M  /zsgtera2	#26
#ztestpool4  3.14T   376G    96K  /ztestpool4	#27

function dum1hf () {
  du --max-depth=1 -h 
}

function scrubpool () {
  cd /$zp
  echo "$PWD" >> $logfile

  dum1hf > /$zp/disk-usage.txt 
  cat /$zp/disk-usage.txt >> $logfile
  chmod 550 /$zp/disk-usage.txt
  chown root:dave /$zp/disk-usage.txt

#  /sbin/
  zpool scrub $zp
  didpool=$zp

  echo "$(date +%H:%M:%S) - START RUN ...waiting for scrub of ZFS pool $zp to complete..." >> $logfile
#	/sbin/
	zpool status -v $zp >> $logfile

#  sleep 20 # wait for spinup if nec
	waitscrub=1
  while [ $waitscrub -gt 0 ];do 
#		waitscrub=`/sbin/zpool status -v $zp |grep -c "scrub in progress"`
		waitscrub=$(zpool status -v $zp |grep -c "scrub in progress")
    sleep 61
#    /sbin/
    zpool status $zp |/bin/egrep 'scanned|repaired' >> $logfile
  done 
  echo "$(date +%H:%M:%S) - STEP DONE ...scrub finished for $zp" >> $logfile

}

# IF poolnum=1 && mydt=24 THEN scrub thispool
#cd /$zp && (echo "o Spinup disks -- DU $zp:" >> $logfile; du -s /$zp >> $logfile 2>/dev/null) 

poolnum=1
for zp in $(zpool list |grep -v NAME |awk '{ print $1 }'); do
	case "$mydt" in
    23 )
			[ "$poolnum" = "1" ] && scrubpool $zp		      
      ;;
    24 )
			[ "$poolnum" = "2" ] && scrubpool $zp		      
      ;;
    25 )
			[ "$poolnum" = "3" ] && scrubpool $zp		      
      ;;
    26 )
			[ "$poolnum" = "4" ] && scrubpool $zp		      
      ;;
    27 )
			[ "$poolnum" = "5" ] && scrubpool $zp		      
      ;;
		* ) 
# all other cases - fallthru
			echo "! NOTE Fallthru happened - mydt=$mydt poolnum=$poolnum zp=$zp" >> $logfile
      ;;
  esac      
	let poolnum=$poolnum+1

done

/sbin/zpool status -v $didpool >> $logfile
echo "$(date +%H:%M:%S) - END RUN $0 Scrub finished for day=$mydt $didpool" >> $logfile

exit;

2017.0903 - removed /sbin refs to zpool commands in case we use src
+ added PATH

#zredtera1	#24
#zsastera1compr #25
#zseatera2	#26
#zseatera4	#27
