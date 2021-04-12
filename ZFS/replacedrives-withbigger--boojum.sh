#!/bin/bash

# TODO test with 320GB -> 500GB

# HOWTO - edit, search this file for TODO and replace things where necessary before running!
# NOTE this script will auto-GPT-label new disks!!!

# NOTE this script is interactive and will wait for PK = presskey/enter

# DEPENDS: parted, working zfs installation

# 2016 Dave Bechtel

# GOAL - replace all disks in pool1 with larger disks ON THE FLY, no downtime;
# Adapted from mkdynpoolbigger-inplace--boojum

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

debugg=1
skipdisk=0   # Leave at 0 unless u know what u doing! for interrupt/resume AND requires manual number below!! xxxxx

logfile=~/replacedrives-withbigger.log
> $logfile # clearit

# TODO EDITME xxxxx change this to the zfs pool you are working on!
zp=zmir320comp

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
    args='placeholder'

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

# This also includes WWN
dpath=/dev/disk/by-id

#dpath=/dev/disk/by-path
# If doing SCSI drives, use this

chkpoolmount=$(df |grep -c $zp)
[ $chkpoolmount -gt 0 ] || zpool import -d $dpath $zp

chkpoolmount=$(df |grep -c $zp)
[ $chkpoolmount -eq 0 ] && failexit 9999 "! $zp was not imported / is still not mounted!"

# assuming: ( TODO paste relevant part of "zpool status" here as map before running )
#        NAME                                          STATE     READ WRITE CKSUM
#        zredtera1                                     ONLINE       0     0     0
#          mirror-0                                    ONLINE       0     0     0
#            ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R  ONLINE       0     0     0
#            ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J6KTJC0J  ONLINE       0     0     0
#          mirror-1                                    ONLINE       0     0     0
#            ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J4KD08T6  ONLINE       0     0     0
#            ata-WDC_WD10EZEX-00KUWA0_WD-WCC1S5925723  ONLINE       0     0     0
                                                                                                            

# xxxxx TODO EDITME change disks here!
declare -a pooldisks 	# regular indexed array
pooldisks[1]=ata-SAMSUNG_HD322HJ_S17AJB0SA23730 
pooldisks[2]=ata-ST3320620AS_9QF4BMH8 
#pooldisks[3]=ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J4KD08T6
#pooldisks[4]=ata-WDC_WD10EZEX-00KUWA0_WD-WCC1S5925723
#pooldisks[5]=zdyndisk5
#pooldisks[6]=zdyndisk6


# associative arrays REF: http://mywiki.wooledge.org/BashGuide/Arrays
# REF: http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/

# NOTE CAPITAL A for assoc array!
declare -A ASrepdisks 	# associative array

# xxxxx TODO EDITME put new disk names / WWN IDs here before running!
# ASrepdisks == New disk name to replace original disk with
key=${pooldisks[1]} # zdyndisk1
ASrepdisks[$key]=ata-ST3500641AS_3PM1523A 
# ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R -make this whatever new disk is in dev/disk/by-id 

key=${pooldisks[2]} # zdyndisk2, or 8 if detected
ASrepdisks[$key]=ata-ST3500641AS_3PM14C8B 
# ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J6KTJC0J

#key=${pooldisks[3]} # zdyndisk3
#ASrepdisks[$key]=zbigrdisk3  
# ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J4KD08T6
#key=${pooldisks[4]} # whatever 4 is set to
#ASrepdisks[$key]=zbigrdisk4  
# ata-WDC_WD10EZEX-00KUWA0_WD-WCC1S5925723

#key=${pooldisks[5]} # whatever 5 is set to
#ASrepdisks[$key]=zbigrdisk5
#key=${pooldisks[6]} # whatever 6 is set to
#ASrepdisks[$key]=zbigrdisk6


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

zpool status -v $zp >> $logfile 

  logecho "Dumping assoc array to log HERE:"
  for K in "${!ASrepdisks[@]}"; do 
    echo $K --- ${ASrepdisks[$K]} >> $logfile
    echo "$zp :INTENT: ZPOOL DISK: $K WILL BE REPLACED WITH: ${ASrepdisks[$K]}" 
  done

#if [ $debugg -gt 0 ]; then
#  echo "CHECK LOG $logfile and PK to proceed!"
#  read
#fi 


################################# TEH MAIN THING
zpool status -v $zp #|logecho
#logecho "`date` - Starting pool size: `df |grep $zp`"
startdata1="$(date) - Starting pool size: "
#startdata2="`df |grep $zp`"
startdata2=$(df|head -n 1)
startdata2=$startdata2'\n'$(df|grep $zp)
echo -e "$startdata2" >> $logfile
#Filesystem                     1K-blocks       Used Available Use% Mounted on
#zredpool2                      722824320   33628416 689195904   5% /zredpool2
#zredpool2/bigvai750           1061294592  372098688 689195904  36% /zredpool2/bigvai750
#zredpool2/dvcompr              898452224  209256320 689195904  24% /zredpool2/dvcompr
#zredpool2/dvds                1270349696  581153792 689195904  46% /zredpool2/dvds

logecho $startdata1
#logecho $startdata2
echo -e "$startdata2"

let startdisk=$skipdisk+1  # FYI only
#printf "o Replacing disks in $zp -- starting with $startdisk -- will end up with bigger pool" # -- ^C to quit!"; #read -n 1   
echo "o Replacing disks in $zp -- starting with $startdisk -- will end up with bigger pool" # -- ^C to quit!"

# xxxxx TODO modify 1st/last disk numbers MANUALLY if nec, does not support vars here
for i in {1..2}; do
	mykey=${pooldisks[$i]} # zdyndisk1
	repdisk=${ASrepdisks[$mykey]} # zbigrdisk1 

	df -h |grep $zp
	logecho "Replacing disk #$i -- $mykey -- Insert Replacement disk: $repdisk into a free slot -- PK or ^C to quit!"
        read -n 1

	(set -x
		zpool labelclear $dpath/$mykey #|| failexit 1000 "! Failed to zpool labelclear $dpath/$mykey"

		parted -s $dpath/$mykey mklabel gpt || failexit 1234 "! Failed to apply GPT label to disk $mykey")

# xxxxx TODO parted on this path MAY NOT WORK, needs to be /dev/sdX ?

# NOTE subshell
# xxxxx THIS IS BEING TESTED!
	 (set -x
	   time zpool replace $zp $dpath/$mykey $dpath/$repdisk || failexit 32768 "! FML, failed to replace disk $dpath/$mykey ")
# END subshell

	zpool status -v $zp >> $logfile
	zpool status -v $zp 

	printf $(date +%H:%M:%S)' ...waiting for resilver to complete...'
	waitresilver=1
	while [ $waitresilver -gt 0 ];do 
	  waitresilver=$(zpool status -v $zp |grep -c resilvering)
	  sleep 2
	done 
	echo 'Syncing to be sure'; time sync;
	date |logecho

        logecho "o OK - we replaced $mykey with $repdisk ... Remove disk $mykey"
        logecho "+ check log and NOTE pool size has increased with every finished mirror column!"

        zpool status -v $zp >> $logfile
	zpool status -v $zp 

	zfs list $zp >> $logfile 
	zpool list $zp >> $logfile 
        logecho "$(date) - Disk $i = $mykey done - DF follows, moving on..."
	df -hT |grep $zp |logecho

done

#ls -lh $lpath # /zdisks/
#zpool status -v $zp

echo "REMEMBER we started with:"
echo "$startdata1"
echo -e "$startdata2"
echo "NOW we have a fully expanded pool with new larger disks:"
echo "$(date) - Pool size after IN-PLACE expansion, NO DOWNTIME:"
echo "$(df |grep $zp)"

echo 'o Complete!'


exit;

2016.0615 SUCCESSFULLY TESTED 320GB > 500GB DISKS :)
