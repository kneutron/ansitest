#!/bin/bash

# 2016 Dave Bechtel

# REQUIRES zdynpool1 on mnt/milterausb3
# run mkdynamic-grow-pool-boojum.sh and keep the pool at the end
# GOAL - replace all disks in zdynpool1 with larger disks ON THE FLY, no downtime;
# + also deal with if disk2 has already been replaced with spare disk8 (mkdynpoolFAIL ran before this)

# FACEPALM - uses different /zdisk path if pool was created (short /zdisks) or imported after reboot (long /mnt../zdisks)

# TODO - add check for already bigrdisk

# NOTE special handling for starting with RAID0 (D1+D2=NOMIR) then adding (1&3 + 2&4=RAID10) 
# -- available space will only increase when an entire MIRROR COLUMN is done!
# assuming:
#        zdynpool1              ONLINE       0     0     0
#  1 *     mirror-0             ONLINE       0     0     0
#      a     /zdisks/zdyndisk1  ONLINE       0     0     0
#      b     /zdisks/zdyndisk3  ONLINE       0     0     0
#  2 *     mirror-1             ONLINE       0     0     0
#      c     /zdisks/zdyndisk2  ONLINE       0     0     0
#      d     /zdisks/zdyndisk4  ONLINE       0     0     0
# To increase available space immediately, we would need to replace 1, then 3 // then 2... and finally 4 

debugg=0
newdisks=1   # SHOULD NORMALLY BE 1 unless ^C before actually replacing ANY disks!
skipdisk=0   # Leave at 0 unless u know what u doing! for interrupt/resume AND requires manual number below!! xxxxx

DS=931  # Disksize in MB
let mkpop=$DS-100  # size of populate-data file in MB


logfile=~/mkpoolbigger-inplace.log
> $logfile # clearit

# TESTING virtual pool failure/hotspare + resilver
zp=zdynpool1

# TODO - can we make things easier by just adding a hotspare Xtimes and replacing with it??

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Echo something to current console AND log
# Can also handle piped input ( cmd |logecho )
# Warning: Has trouble echoing '*' even when quoted.
function logecho () {
  args=$@

  if [ -z "$args" ]; then
    args='tmp'

    while [ 1 ]; do
      read -e -t2 args

      if [ -n "$args" ]; then
         echo "$args" |tee -a $logfile;
      else
        break;
      fi
    done

  else
    echo "$args" |tee -a $logfile;
  fi
} # END FUNC

# xxx TODO EDITME
lpath=/mnt/milterausb3/zdisks
spath=/zdisks

chkpoolmount=$(df |grep -c $zp)
[ $chkpoolmount -gt 0 ] || zpool import -d $lpath $zp
#[ $chkpoolmount -gt 0 ] || zpool import -d /zdisks zdynpool1
# NOTE for some rsn import doesnt use short /zdisks path!

chkpoolmount=$(df |grep -c $zp)
[ $chkpoolmount -eq 0 ] && failexit 9999 "! $zp was not imported / is still not mounted!"

# assuming: (if mkdynpoolFAIL-boojum.sh has run, otherwise disk8 will be disk2
#        zdynpool1                              ONLINE       0     0     0
#          mirror-0                             ONLINE       0     0     0
#            /mnt/milterausb3/zdisks/zdyndisk1  ONLINE       0     0     0
#    *       /mnt/milterausb3/zdisks/zdyndisk8  ONLINE       0     0     0
#          mirror-1                             ONLINE       0     0     0
#            /mnt/milterausb3/zdisks/zdyndisk3  ONLINE       0     0     0
#            /mnt/milterausb3/zdisks/zdyndisk4  ONLINE       0     0     0
#          mirror-2                             ONLINE       0     0     0
#            /mnt/milterausb3/zdisks/zdyndisk5  ONLINE       0     0     0
#            /mnt/milterausb3/zdisks/zdyndisk6  ONLINE       0     0     0
                                                                                                            

declare -a pooldisks # regular indexed array
pooldisks[1]=zdyndisk1
pooldisks[2]=zdyndisk2
pooldisks[3]=zdyndisk3
pooldisks[4]=zdyndisk4
pooldisks[5]=zdyndisk5
pooldisks[6]=zdyndisk6

chkalreadyfailed=$(zpool status -v $zp|grep -c disk8)
if [ $chkalreadyfailed -gt 0 ];then 
 #FAILD=8;REPW=2
 pooldisks[2]=zdyndisk8
fi

[ $debugg -gt 0 ] && logecho "vdisk2: ${pooldisks[2]}"

# associative arrays REF: http://mywiki.wooledge.org/BashGuide/Arrays
# REF: http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/

# NOTE CAPITAL A for assoc array!
declare -A ASrepdisks 	# associative array

# ASrepdisks == New disk name to replace original disk with
key=${pooldisks[1]} # zdyndisk1
ASrepdisks[$key]=zbigrdisk1  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R -make this whatever new disk is in dev/disk/by-id 

key=${pooldisks[2]} # zdyndisk2, or 8 if detected
ASrepdisks[$key]=zbigrdisk2  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J6KTJC0J

key=${pooldisks[3]} # zdyndisk3
ASrepdisks[$key]=zbigrdisk3  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J4KD08T6
key=${pooldisks[4]} # whatever 4 is set to
ASrepdisks[$key]=zbigrdisk4  # ata-WDC_WD10EZEX-00KUWA0_WD-WCC1S5925723
key=${pooldisks[5]} # whatever 5 is set to
ASrepdisks[$key]=zbigrdisk5
key=${pooldisks[6]} # whatever 6 is set to
ASrepdisks[$key]=zbigrdisk6

# ^^ HOW THIS WORKS:
# key=${pooldisks[1]} 				# returns: LET key=zdyndisk1
# ASrepdisks[$key]=zbigrdisk1  # ASrepdisks["zdyndisk1"]="zbigrdisk1"  # LOOKUP and set!
# key=${pooldisks[2]} 				# returns: LET key=zdyndisk8 , if it was manually set, or zdyndisk2 otherwise
# ASrepdisks[$key]=zbigrdisk2  # ASrepdisks["zdyndisk8"]="zbigrdisk2" or whatever you want NEW disk to be

  
if [ $debugg -gt 0 ]; then
# minor sanity chk
  logecho "key:$key: ASrepdisks $key == ${ASrepdisks[$key]}"
#  echo "PK to proceed if OK"
#  read
fi

# Evidently we can only do 1 setting at a time... turn trace=on for this 1 command in subshell
(set -x
  zpool set autoexpand=on $zp) || failexit 99 "! Something failed with $zp - Run mkdynamic-grow-pool-boojum.sh to Create $zp"
(set -x
  zpool set autoreplace=on $zp) || failexit 992 "! Something failed with $zp - Run mkdynamic-grow-pool-boojum.sh to Create $zp"

cd /zdisks || failexit 101 "! Cannot cd /zdisks; does $zp exist?"
chkdisk=${pooldisks[2]}
[ $debugg -gt 0 ] && logecho "o Checking for existence of /zdisks/$chkdisk"
[ -e $chkdisk ] || failexit 105 "! $lpath/$chkdisk does not exist! Run mkdynamic-grow-pool-boojum.sh to Create $zp before running $0 !"

zdpath=/tmp/failsafe  
# if milterausb3 is mounted, use it
usemil=$(df |grep -c /mnt/milterausb3)
if [ $usemil -gt 0 ]; then
  zdpath="/mnt/milterausb3/zdisks" 
else
  failexit 404 '/mnt/milterausb3 needs to be mounted!'
fi


mkdir -pv $zdpath
ln $zdpath /zdisks -sfn
cd /zdisks || failexit 1011 "! Still cant cd to /zdisks! Check $logfile"

# DONE move up
#DS=800  # Disksize in MB
#let mkpop=$DS-100  # size of populate-data file in MB


if [ $newdisks -gt 0 ]; then
  logecho "$(date) - Preparing NEW set of Larger ($DS)MB virtual disks, no matter if they exist or not..."
  for i in {1..8};do
    printf $i...
    (time dd if=/dev/zero of=zbigrdisk$i bs=1M count=$DS 2>&1)  >> $logfile
  done
else
  logecho "Skipping new bigger disk creation"
fi

logecho "$(date) - Syncing..."
time sync

# should now have zdyndisk1-8 PLUS zbigrdisk1-8
#ls -alh |logecho 
du -h z* |logecho  # cleaner ;-)

zpool status -v $zp >> $logfile 

  logecho "Dumping assoc array to log HERE:"
  for K in "${!ASrepdisks[@]}"; do 
    echo $K --- ${ASrepdisks[$K]} >> $logfile
    echo "$zp :INTENT: ZPOOL DISK: $K WILL BE REPLACED WITH: ${ASrepdisks[$K]}" 
  done

# check if pool was imported after reboot, uses longer path!
chklongpath=$(zpool status -v |grep -c milterausb3)
if [ $chklongpath -gt 0 ]; then
  usepath=$lpath
  logecho "Using longer path $usepath"
else
  usepath=$spath
  logecho "Using shorter path $usepath"
fi

if [ $debugg -gt 0 ]; then
  echo "CHECK LOG $logfile and PK to proceed!"
  read
fi 


################################# TEH MAIN THING
zpool status -v $zp #|logecho
#ls -lh /zdisks/ |logecho
#logecho "`date` - Starting pool size: `df |grep $zp`"
startdata1="$(date) - Starting pool size: "
startdata2="(df |grep $zp)"
logecho $startdata1
logecho $startdata2

let startdisk=$skipdisk+1  # FYI only
#printf "o Replacing disks in $zp -- starting with $startdisk -- will end up with bigger pool" # -- ^C to quit!"; #read -n 1   
echo "o Replacing disks in $zp -- starting with $startdisk -- will end up with bigger pool" # -- ^C to quit!"

# xxxxx TODO modify 1st/last disk numbers MANUALLY if nec, does not support vars here
for i in {1..6}; do
	mykey=${pooldisks[$i]} # zdyndisk1
	repdisk=${ASrepdisks[$mykey]} # zbigrdisk1 

	df -hT |grep $zp
	logecho "Replacing disk #$i -- $mykey -- OTF with Replacement disk: $repdisk - PK or ^C to quit!"
read -n 1

# NOTE subshell
	 (set -x
	   time zpool replace $zp $usepath/$mykey $usepath/$repdisk || failexit "32768 FML")
# END subshell

#ls -lh /zdisks/
	zpool status -v $zp #|logecho

	printf $(date +%H:%M:%S)' ...waiting for resilver to complete...'
	waitresilver=1
	while [ $waitresilver -gt 0 ];do 
	  waitresilver=$(zpool status -v $zp |grep -c resilvering)
	  sleep 2
	done 
	echo 'Syncing to be sure'; time sync;
	date |logecho

        logecho "o OK - we replaced $mykey with $repdisk ..."
        logecho "+ check log and NOTE pool size has increased with every finished mirror column!"

	zpool status -v $zp #|logecho
        zpool status -v $zp >> $logfile

	zfs list $zp >> $logfile # |logecho
	zpool list $zp >> $logfile # |logecho
        logecho "$(date) - Disk $i = $mykey done - DF follows:"
	df |grep $zp |logecho

done

#ls -lh $lpath # /zdisks/
#zpool status -v $zp

echo "REMEMBER we started with:"
echo "$startdata1"
echo "$startdata2"
echo "NOW we have a fully expanded pool with new larger disks:"
echo "$(date) - Pool size after IN-PLACE expansion, NO DOWNTIME:"
echo "$(df |grep $zp)"

echo 'o Complete!'

exit;

