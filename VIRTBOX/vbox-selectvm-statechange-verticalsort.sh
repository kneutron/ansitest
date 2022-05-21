#!/bin/bash

# Script version:
scrver="2022_0521@1345"
# xxx TODO editme ^^

# Select from a list of known virtualbox VMs, which to stop/start - can handle multiple like 1,3,5

# REQUIRES VboxManage, tr, pr, grep, awk, sed, tee, bash version > 3.2.57(1)-release

#NOTE running vms that are still "coming up" from disk-saved state are NOT considered as "running"
# until they are all the way up!

# This script will XOR the state of a VM - if running, it will Stop it; if not running, it will Start it.
# Entering "all" will STOP all running VMs

# NOTE Cleaning up the logfile when it gets too big is left as an exercise for the end-user :B
logf=$HOME/vms-stopped-started.log
vbm=VBoxManage

debugg=0

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit "$1"
}

function stopvm () {
  echo "$(date) - $(whoami) Stopping VM ${vm} / ${vmuuid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $vbm controlvm ${vmuuid} savestate && echo "$(date) - $vm is now stopped" |tee -a "$logf"
# Dont actually stop any if debugging
}

function startvm () {
  echo "$(date) - $(whoami) Starting VM ${vm} / ${vmuuid}" |tee -a "$logf"
[ $debugg -eq 0 ] && time $vbm startvm ${vmuuid} && echo "$(date) - $vm is now running" |tee -a "$logf"
# Dont actually start any if debugging
}


########## MAIN
echo "o-> Utility to change state of a virtualbox VM -stop if running, +start if not running | v.$scrver-$debugg <-o"  

if [ "$1" = "s" ] || [ "$1" = "" ]; then
# select ; REF: https://www.baeldung.com/linux/reading-output-into-array
  runtest=$($vbm list runningvms)
  if [ "$runtest" = "" ]; then
    echo "FYI: No VMs are currently running under ID $(whoami)"
  else
    echo "( $(echo "$runtest" |grep -c \}) ) VMs are currently running" # ya, its a hack :B
  fi

  OIFS="$IFS"
  IFS=$'\n'
# populate array with list of known VMs
  declare -a vmlist=( $($vbm list vms |tr -d '"' |sort) )
#LiveCD--64 {hexnum}

  maxvmnum=${#vmlist[@]} # of elements in array
  IFS="$OIFS"

cols=$(stty size |awk '{print $2}') # columns / terminal size - REF: https://stackoverflow.com/questions/1780483/lines-and-columns-environmental-variables-lost-in-a-script
  # dump array - REF: https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
  for i in ${!vmlist[@]}; do
     chkrun=$(echo $runtest |grep -c $(echo ${vmlist[$i]} |awk '{print $2}') ) # check is this uuid in running?
     if [ $chkrun -gt 0 ]; then
        echo "$i + ${vmlist[$i]}" # Prefix with "+" to indicate running
     else
       echo "$i - ${vmlist[$i]}" # - = not running
     fi
  done |tr -d '"{}' |pr -2 -t -w $cols |awk 'NF>0'
# Remove quotes and brackets from output, vertical output with 'pr', no blank lines
# ISSUE - interesting, $COLUMNS is not avail at runtime! but we can get from stty size field 2
# FEATURE: fancy display in 2 columns sorted vertically  

#  done |tr -d '"{}' |awk '{print $1" "$2" "$3}' |paste - - |column -t
# Old way - fancy display in 2 columns; $1=number of entry, $2=nameofvm, $3=vmUUID

  echo -n "+=ON; Enter comma-separated number(s) of VM to XOR, or all to stop-all: "
  read vmn
#  echo "You selected $vmn"
else
  vm="$1"
fi

[ $debugg -gt 0 ] && set -x

# auto-lowercase it for convenience
vmn=${vmn,,}
test4comma=$(echo $vmn |grep -c ',')

if [ "$vmn" = "all" ]; then
# we are assuming there is no concievable way an end-user would want to XOR the state of every.single.vm
  STOPALLVMS.sh # external script, needs to be in PATH
  exit;

elif [ $test4comma -gt 0 ]; then
# vmn is comma-separated, multiple "1,3,5"
  procthese="$vmn"
# SANITY
  while [ $(echo "$procthese" |grep -c ',,') -gt 0 ]; do
    procthese=$(echo "$procthese" |sed 's/,,/,/g') # get rid of multiple commas JIC
  done

  procthese=$(echo $procthese |sed 's/ //g') # get rid of spaces
  procthese=$(echo $procthese |sed 's/^,//g') # get rid of leading comma (extraneous)
  procthese=$(echo $procthese |sed 's/,$//g') # get rid of trailing comma (extraneous)

  echo "After sanity checks, will be processing: $procthese"

# REF: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash#tab-top 
  oIFS="$IFS"
  IFS=","
  declare -a dothese=($procthese)
  IFS="$oIFS"
   
# xxx new
  for procthisvmnum in "${dothese[@]}" ;do

# sanity - REF: https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
    regexp='^[0-9]+$' # yes, I know it should probably go outside the loop but easier to read
    if ! [[ $procthisvmnum =~ $regexp ]] ; then
      echo "Error: $procthisvmnum is Not a number" |tee -a "$logf"

      continue; # next iteration
    fi

# we are zero-indexed, remember so -1 less than what we know
    if [ $procthisvmnum -ge $maxvmnum ]; then 
      let whatweknow=$maxvmnum-1
      echo "Invalid VM number $procthisvmnum , outside max known: $whatweknow" |tee -a "$logf"

      continue; # next iteration
    fi
    
    vm=${vmlist[$procthisvmnum]} # get name + uuid from "known" array
[ $debugg -gt 0 ] && echo "vm: $vm" 
[ "$vm" = "" ] && failexit 45 "$vm not found in list!"    

    vmuuid=$(echo $vm |tr -d '{}' |awk '{print $2}') # take out brackets and only print uuid
[ $debugg -gt 0 ] && echo "vmuuid: $vmuuid" 
    vm=$(echo "$vm" |tr -d '"' |awk '{print $1}') # take out quotes and only print name, note we are changing the vbl so uuid has 2b b4

# check cur list of Running vms against known array info - BUGFIX check for uuid, not name!
#    stopthis=$(VBoxManage list runningvms |awk '/'$vm'/ {print $2}' |tr -d '{}') # get vm uuid + remove brackets
    stopthis=$(VBoxManage list runningvms |awk '/'$vmuuid'/ {print $2}' |tr -d '{}') # get vm uuid + remove brackets
[ $debugg -gt 0 ] && echo "stopthis / vmuuid: $stopthis / $vmuuid"
    if [ "$stopthis" = "" ]; then
      startvm $vmuuid # $vm
    else
      stopvm $vmuuid # $stopthis 
    fi
  done

else
# Single VM, either a number or passed as arg
  if [ "${#vmn}" -gt 0 ]; then 
# check length, user entered selection

# sanity - REF: https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
    re='^[0-9]+$' # why is varname different here? for debugging
    if ! [[ $vmn =~ $re ]] ; then
      failexit 10 "Error: $vmn is Not a number" 
    fi

    if [ $vmn -ge $maxvmnum ]; then
      let whatweknow=$maxvmnum-1
      echo "Invalid VM number $vmn , outside max known: $whatweknow" |tee -a "$logf"
      failexit 250 "Invalid VM index number"
    fi

    vm=${vmlist[$vmn]}
# get name by number from array - NOTE if this equates to 0 somehow, it still works - was BUG if you enter random text as selection
    vmuuid=$(echo $vm |tr -d '{}' |awk '{print $2}') # take out brackets and only print uuid
  fi

  vm=$(echo "$vm" |tr -d '"' |awk '{print $1}') # take out quotes and only print name

  # take out brackets and only print uuid
  [ "$vmuuid" = "" ] && vmuuid=$($vbm list vms |grep "$vm" |awk '{print $2}' |tr -d '{}')
  [ "$vmuuid" = "" ] && failexit 46 "Cannot find uuid for $vm / unknown VM?"

 # stopthis=$(VBoxManage list runningvms |awk '/'$vm'/ {print $2}' |tr -d '{}') # remove brackets
  stopthis=$(VBoxManage list runningvms |awk '/'$vmuuid'/ {print $2}' |tr -d '{}') # remove brackets
# BUGFIX search running for uuid, not name  
  if [ "$stopthis" = "" ]; then
    startvm $vmuuid # $vm
  else
    stopvm $vmuuid # $stopthis 
  fi

fi

date;

ls -lh "$logf"

exit;

# 2022.0520 Dave Bechtel
# Adapted from: vbox-selectvm-statechange / vbox-select-stopvm.sh

# Feature: display sorted vertically with ' pr -2 ' instead of paste
# NOTE this one uses vertical-sorted display and haz Extra Sanity

# The script:
# o Smart enough to XOR a VM if you pass it the UUID (without the brackets) or vmname as arg :)
# o Will not care if you put in the same number two or more times(!)
# o Does NOT process ranges, like 1-3 or 1..3 -- only comma-separated


# helpful aliases:
alias vb='wmctrl -s 2; virtualbox &'
alias vbm='VBoxManage '
alias vb-listvms="VBoxManage list vms |tr -d '\"{}' |awk '{print \$1,\$2}' |sort |column -t"
alias vb-listvms-short="VBoxManage list vms |tr -d '\"{}' |awk '{print \$1}' |sort |paste - - |column -t"
alias vb-listvmsv="VBoxManage list vms |tr -d '\"{}' |awk '{print \$1,\"/ \"\$2}' |sort |pr -2 -t -w $(stty size|cut -d' ' -f2) |awk 'NF>0'"
alias vb-listrunning='VBoxManage list runningvms'
alias vb-listrunningnobracket="echo $(VBoxManage list runningvms |awk '{print $2}' |tr -d '{}')"


# FIX In all cases, we should pass the UUID to stop/start in case of dup vm names to avoid confusion...
# FIX + standardized date format in logfile

# fixed single-vm treatment, check if single-vm index number outside known, dont failexit if no vms are running

# tested crazy input like ,,,,,,,,,99,,,,,31,,,gob,,0,,,,,,,, and added sedloop 

# BUGfixed - counting more than 1 comma in 1 line with grep -c fails:
# + fixed with awk REF: https://stackoverflow.com/questions/10817439/counting-commas-in-a-line-in-bash
# tmp=",5,0"
#echo $tmp |grep -c ',' # not reliable!
#1

# FIX Made max-known vm number more palatable when displaying if we-cant-do-that
# + Updated requires: list of external progs

# display version+debugg on run

#FIXED BUG: ,,,,0,,,, starts/stops!!
#FIXED: mixing up similarly-named VMs / uuids

# 2022.0521 chomping 1, onthefly from the front is buggy - sep into array after sanity = works better, no doubling

# v20220521.1345 + added feature to display "+" if VM running, - if not
# -removed extraneous comments / oldcode
