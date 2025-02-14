#!/bin/bash

# 2025.Feb kneutron
# Mod for proxmox - original script was created for virtualbox

# Run from server console or root/ssh
# Give sysadmin the opportunity to hibernate/run LXC/VM(s) without GUI

# Flips the state of a stopped/running LXC/VM on the current node
# Works on BOTH LXC and VM for simplicity
# Just pass the VMID number or name, script will determine what it is and what state it's in, on the fly

# Enter multiple LXC/VM IDs separated by commas interactively
# Or pass a single VMID / name as argument

# Example:
# $0 101	# start LXC/VM 101 if not running, 		HIBERNATE VM if it's on, STOP if LXC
# $0 livecd	# start LXC/VM 101 "livecd" if not running, 	HIBERNATE VM if it's on, STOP if LXC
# $0		# Interactive input

# As of this writing (2025.Feb) " pct suspend " is Experimental according to man page, so not trying it - only stop

# It is suggested to soft-symlink / alias this script to " selectvm " or something shorter, for simplicity


# if running from cron, we need this
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

# Script version:
scrver="2025_0213@1645"
# xxx TODO editme ^^

# Select from a list of proxmox LXC/VMs, which to stop/start - can handle multiple like 1,3,5 - comma-separated only

# REQUIRES: tr, pr, grep, awk, sed, tee, wc, sort, tail, stty

#NOTE running vms that are still "coming up" from disk-saved state are NOT considered as "running"
# until they are all the way up!

# This script will XOR the state of a VM - if running, it will Stop it; if not running, it will Start it.
# Entering "all" will STOP all running VMs


# NOTE Cleaning up the logfile when it gets too big is left as an exercise for the end-user :B
logf=$HOME/vms-stopped-started.log
lxclistf=/dev/shm/lxclist-tmp.in
vmlistf=/dev/shm/vmlist-tmp.in
combinedf=/dev/shm/combinedlxcvm.in

lxccmd=pct
vmcmd=qm

# TODO EDITME
# if 1, do not actually start/stop - just log
# if 2, trace = on
debugg=0


# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit "$1"
}

function stoplxc () {
  vmid=$1
  vmname=$2
  echo "$(date) - $(whoami) Stopping LXC ${vmname} / ${vmid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $lxccmd stop ${vmid} && echo "$(date) - LXC $vmid is now stopped" |tee -a "$logf"
# Dont actually stop any if debugging
}

function startlxc () {
  vmid=$1
  vmname=$2
  echo "$(date) - $(whoami) Starting LXC ${vmname} / ${vmid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $lxccmd start ${vmid} && echo "$(date) - LXC $vmid is now running" |tee -a "$logf"
# Dont actually start any if debugging
}

# Note HIBERNATES
function stopvm () {
  vmid=$1
  vmname=$2
  echo "$(date) - $(whoami) Hibernating VM ${vmname} / ${vmid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $vmcmd suspend ${vmid} --todisk && echo "$(date) - $vmid is now hibernated" |tee -a "$logf"
# Dont actually hiber any if debugging; replace with "stop" to not hibernate
}

function startvm () {
  vmid=$1
  vmname=$2
  echo "$(date) - $(whoami) Starting VM ${vmname} / ${vmid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $vmcmd start ${vmid} && echo "$(date) - $vmid is now running" |tee -a "$logf"
# Dont actually start any if debugging
}


echo "$(date) - Getting list of LXC/VMs on this node"
time $lxccmd list |grep -v VMID |awk '{print $1" "$2" "$3'} >$lxclistf 
time $vmcmd list |grep -v VMID |awk '{print $1" "$3" "$2'} >$vmlistf # NOTE: correct the field order to be same as lxc == vmid / state / name
cat $lxclistf $vmlistf |sort -n >$combinedf

function col
{
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${COL}"
}


########## MAIN
clear
echo -n "o-> Utility to change state of a Proxmox LXC/VM -stop if running, +start if not running | v.$scrver-$debugg <-o";xpos=$(col)
echo '' # ; echo "xpos: $xpos"
#text=abc; printf "%*s\\n" $(((${#text}+$(tput cols)/2))) "$text" # center

#if [ "$1" = "s" ] || [ "$1" = "" ]; then
[ "$1" = "" ] || vmn=$1
# select ; REF: https://www.baeldung.com/linux/reading-output-into-array
  runtest=$(grep running $lxclistf)
  runtest+=" $(grep running $vmlistf)" # append; need space added for word match 

  if [ "$runtest" = "" ]; then
    pt="FYI: No LXC/VMs are currently running"
    printf "%*s\\n" $(( (${#pt}+$(($xpos/2)) ))) "$pt" # center
  else
    tmp1=$(grep -c running $lxclistf)
    tmp2=$(grep -c running $vmlistf)
    let tmp3=$tmp1+$tmp2
    pt="( $tmp3 ) LXC/VMs are currently running" # FIX
    printf "%*s\\n" $(( (${#pt}+$(($xpos/2)) ))) "$pt" # center
#    printf "%*s\\n" $(((${#pt}+$(tput cols)/2))) "$pt" # center
#    echo "( $(echo "$runtest" |grep -c running) ) LXC/VMs are currently running" # BUG - returns actual -1
  fi

# not really used, just ref
#runninglxc=$(grep running $lxclistf)
#runningvms=$(grep running $vmlistf)

OIFS="$IFS"
IFS="
" # $'\n'

[ $debugg -gt 1 ] && set -x
  tmp1=$(wc -l $lxclistf |awk '{print $1}') # of lines
  tmp2=$(wc -l $vmlistf |awk '{print $1}') 
  let totalvms=$tmp1+$tmp2

  maxvmnum=$(tail -n1 $combinedf |awk '{print $1}')

cols=$(stty size |awk '{print $2}') # columns / terminal size - REF: https://stackoverflow.com/questions/1780483/lines-and-columns-environmental-variables-lost-in-a-script

  for line in $(cat $combinedf); do
     tmpvmid=$(echo "$line" |awk '{print $1}')
#[ "$tmpvmid" -eq "104" ] && set -x || set +x 	# DEBUGG
     chkrun=$(echo "$runtest" |grep -w -c $tmpvmid) # check is this vmid in running string?
     tmpvar=$(echo "$line" |awk {'print $3'}) 

     if [ $chkrun -gt 0 ]; then
       echo "$tmpvmid + $tmpvar" # Prefix vmid,name with "+" to indicate running
     else
       echo "$tmpvmid - $tmpvar" # "-" = not running
     fi
  done |pr -2 -t -w $cols |awk 'NF>0'
  IFS="$OIFS"
# Vertical output with 'pr', no blank lines
# ISSUE - interesting, $COLUMNS is not avail at runtime! but we can get from stty size field 2
# FEATURE: fancy display in 2 columns sorted vertically  

  echo -n "+=ON; Enter comma-separated number(s) of VM to XOR, or all to stop-all: "
  [ "$1" = "" ] && read vmn

#[ $debugg -gt 1 ] && set -x # DEBUGG

# auto-lowercase it for convenience
vmn=${vmn,,}
#test4comma=$(echo $vmn |grep -c ',')

if [ "$vmn" = "all" ] && [ "$vmn" = "ALL" ]; then
# we are assuming there is no concievable way an end-user would want to XOR the state of every.single.vm
  proxmox-HIBER-RUNNING-VMS.sh # external script, needs to be in PATH
  exit;
fi

set +x # stop DEBUGG
set -u # Error if var undefined
# vmn is comma-separated, multiple "1,3,5"
  procthese="$vmn"

# SANITY
  procthese=$(echo "$procthese" |tr -d '.') # get rid of any dots

  while [ $(echo "$procthese" |grep -c ',,') -gt 0 ]; do
    procthese=$(echo "$procthese" |sed 's/,,/,/g') # get rid of multiple commas JIC
  done

  procthese=$(echo "$procthese" |sed 's/ //g') # get rid of spaces
  procthese=$(echo "$procthese" |sed 's/^,//g') # get rid of leading comma (extraneous)
  procthese=$(echo "$procthese" |sed 's/,$//g') # get rid of trailing comma (extraneous)

  echo '==================='
  echo "After sanity checks, will be processing: $procthese" |tee -a "$logf"

# REF: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash#tab-top 
  oIFS="$IFS"
  IFS=","
  declare -a dothese=($procthese)
  IFS="$oIFS"


# Process the list of VMIDs  
# xxx new
  for tmpvmnum in "${dothese[@]}"; do
    procthisvmnum=$tmpvmnum

# NOTWORK
#    tryfindname="" # if name was passed instead of number 
#    tryfindname=$(grep -c "$procthisvm" $combinedf)
#    rc=$?
#    if [ $tryfindname -eq 0 ] || [ "$rc" = "1" ]; then 
#      echo "Error: $procthisvmnum is Not a number or known LXC/VM name" |tee -a "$logf"
#
#      continue; # next iteration
#    else
#      echo "INFO: Found VMID from name $procthisvmnum" |tee -a "$logf"
#      procthisvmnum=$(grep "$procthisvmnum" $combinedf |awk '{print $1}')
#    fi
  
    result=""
    result=$(grep -w "$procthisvmnum" $combinedf |head -n 1 |awk '{print $1}') # get VMID regardless, ignore multiple results, only return 1st
    [ "$result" = "" ] || procthisvmnum=$result    

# sanity - REF: https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
    regexp='^[0-9]+$' # yes, I know it should probably go outside the loop but easier to read
    if ! [[ $procthisvmnum =~ $regexp ]]; then
      echo "Error: $procthisvmnum is Not a number" |tee -a "$logf"

      continue; # next iteration
    fi

    if [ $procthisvmnum -gt $maxvmnum ]; then 
      echo "Error: Invalid VM number $procthisvmnum , outside max known: $maxvmnum" |tee -a "$logf"

      continue; # next iteration
    fi
    
    vm=$(grep -w "$procthisvmnum" $combinedf |awk '{print $3}') # get name from "known" file
[ $debugg -gt 0 ] && echo "vm: $vm / procthisvmnum: $procthisvmnum" 

# check cur list of Running lxc/vms against known info 
    foundinlxcfile=$(grep -w -c $procthisvmnum $lxclistf)
    foundinvmfile=$(grep -w -c $procthisvmnum $vmlistf)
    
    if [ $foundinlxcfile -eq 0 ] && [ $foundinvmfile -eq 0 ]; then
      echo "Error: $procthisvmnum Not found in either LXC or VM list!"
      
      continue;
    fi
 
    if [ $foundinlxcfile -gt 0 ]; then
      chkrun=$(echo "$runtest" |grep -w -c $procthisvmnum) # check is this vmid in running LXC?
      
      case $chkrun in 
        1) 
          stoplxc $procthisvmnum $vm ;;
        0)
          startlxc $procthisvmnum $vm ;;
        *)
          echo "Killme, I should never be here!" ;;
      esac
    fi   

    if [ $foundinvmfile -gt 0 ]; then
      chkrun=$(echo "$runtest" |grep -w -c $procthisvmnum) # check is this vmid in running VMs?
      
      case $chkrun in 
        1) 
          stopvm $procthisvmnum $vm ;;
        0)
          startvm $procthisvmnum $vm ;;
        *)
          echo "Killme2, I should never be here!" ;;
      esac
    fi   
  done # procthisvmnum / dothese

date;

echo '========' |tee -a $logf
ls -lh "$logf"

# call this again (kiosk mode) - TODO test for interactive
#exec $0

exit;


# multiline bash comment
: >>'EOF'

# 2025.Feb / 2022.0520 Dave Bechtel
# Adapted from: vbox-selectvm-statechange-verticalsort.sh 

# Feature: display sorted vertically with ' pr -2 ' instead of paste
# NOTE this one uses vertical-sorted display and haz Extra Sanity

# The script:
# o Smart enough to XOR a VM if you pass it the VMID or vmname as arg :)
# o Will not care if you put in the same number two or more times(!)
# o Does NOT process ranges, like 1-3 or 1..3 -- only comma-separated

Example output:

o-> Utility to change state of a Proxmox LXC/VM -stop if running, +start if not running | v.2025_0213@1645-0 <-o
                                                        ( 11 ) LXC/VMs are currently running
100 - lmde-zfstest                                                                                         118 + proxmox-fileserver-ctr
101 - pxenetboot                                                                                           119 - ubuntu-ansible-controller
102 - livecd                                                                                               120 + pbs-bkp-4-beelink-vms
103 - rocky-linux-9                                                                                        121 + suse-iscsi-proxmox-macmini
104 + popos-boinc                                                                                          122 - test-phone-tether
105 + gotify                                                                                               123 - casaos-debian
106 - livecd2                                                                                              124 - nextcloud-turnkey-debian
107 - win11-choco                                                                                          125 - test-restore-qotom-proxmox
108 - minimal-debian-fluxbox-xrdp-thunderbird                                                              126 - pve-test-unattended-install
109 + opnsense-dhcp-for-2p5Gbit                                                                            127 - macpro-lmde5-upgrade-test
110 - suseleap-ctr-p                                                                                       128 - ubuntu
111 + ipfire-dhcp-for-10gig                                                                                129 - proxmox-zfs-root-mirror-test-efiboot
112 + win10-net-iso-install-boinc                                                                          133 - win10-pro-lenovo-520-restore-veeam
113 + hostonly-dhcp-ctr-server-no-internet                                                                 134 - alma8-docker-no-stig-test
114 - debianctr-xorgtest                                                                                   135 - debian-qdevice-replacement
115 - proxmox-test-lvm-resize                                                                              136 - authelia-ctr-priv-debian
116 + squidvm-new-2p5-10-HO                                                                                137 + suse-iscsi-proxmox-macpro
117 - win10-22H2-upgrade-test                                                                              1037 - suse-leap-iscsi-template
+=ON; Enter comma-separated number(s) of VM to XOR, or all to stop-all: ^C


2024.0601 FIX if user enters vm number as arg

# We only need the 1st 3 fields
# pct list|grep runn
105        running                 gotify              
113        running                 hostonly-dhcp-ctr-server-no-internet
118        running                 proxmox-fileserver-ctr
# qm list|grep runn  # NOTE - DIFFERENT FIELD ORDER!
104 popos-boinc          running    7168              40.00 873244    
109 opnsense-dhcp-for-2p5Gbit running    1288              22.00 6796      
111 ipfire-dhcp-for-10gig running    512               16.00 7223      
112 win10-net-iso-install-boinc running    6144              40.00 3286018   
116 squidvm-new-2p5-10-HO running    4096              16.00 5930      
120 pbs-bkp-4-beelink-vms running    4096              20.00 9161      
121 suse-iscsi-proxmox-macmini running    4096              32.00 9703      
137 suse-iscsi-proxmox-macpro running    4096              40.00 10218     

# FIX In all cases, we should pass the VMID to stop/start in case of dup vm names to avoid confusion...
# FIX + standardized date format in logfile

# fixed single-vm treatment, check if single-vm index number outside known, dont failexit if no vms are running

# tested crazy input like ,,,,,,,,,99,,,,,31,,,gob,,0,,,,,,,, and added sedloop 

# BUGfixed - counting more than 1 comma in 1 line with grep -c fails:
# + fixed with awk REF: https://stackoverflow.com/questions/10817439/counting-commas-in-a-line-in-bash
# tmp=",5,0"
#echo $tmp |grep -c ',' # not reliable!
#1

# FIX Made max-known vm number more palatable when displaying if we-cant-do-that

# display version+debugg on run

#FIXED BUG: ,,,,0,,,, starts/stops!!
#FIXED: mixing up similarly-named VMs / vmids

# 2022.0521 chomping 1, onthefly from the front is buggy - sep into array after sanity = works better, no doubling

# v20220521.1345 + added feature to display "+" if VM running, - if not
# -removed extraneous comments / oldcode
EOF
