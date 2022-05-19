#!/bin/bash

# Select from a list of running virtualbox VMs, which to stop - can handle multiple like 1,3,5

# REQUIRES VboxManage, tr, awk, sed, bash version > 3.2.57(1)-release

#NOTE running vms that are still "coming up" from disk-saved state are NOT
# considered as "running" until they are all the way up!

# NOTE pass arg1="s" to Select from list (will prompt)


# NOTE Cleaning up the logfile when it gets too big is left as an exercise for the end-user :B
logf=$HOME/vms-stopped.log
vbm=VBoxManage

debugg=0

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

function stopvm () {
  echo "$(date) - $(whoami) Stopping VM ${vm}" |tee -a $logf
[ $debugg -eq 0 ] && time $vbm controlvm $stopthis savestate
# Dont actually stop any if debugging
}


########## MAIN
if [ "$1" = "s" ] || [ "$1" = "" ]; then
# select ; REF: https://www.baeldung.com/linux/reading-output-into-array
  runtest=$($vbm list runningvms)
  [ "$runtest" = "" ] && failexit 44 "No VMs are running under ID $(whoami)"

  OIFS=$IFS
  IFS=$'\n'
# populate array with list of running
  declare -a vmlist=( $($vbm list runningvms) )
#"LiveCD--64" {fe588d0f-88dc-4969-99ae-49defa321acf}

  IFS=$OIFS
  
  # dump array - REF: https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
  for i in ${!vmlist[@]}; do
     echo "$i ${vmlist[$i]}"
  done

  echo -n "Enter comma-separated number(s) of VM to stop, or all: "
  read vmn
else
  vm=$1
fi

echo "You selected $vmn"
[ $debugg -gt 0 ] && set -x

# auto-lowercase it for convenience
vmn=${vmn,,}
if [ "$vmn" = "all" ]; then
  STOPALLVMS # external script, needs to be in PATH
  exit;

elif [ $(echo $vmn |grep -c ',') -gt 0 ]; then
# vmn is comma-separated, multiple "1,3,5"
  procthese="$vmn"
# SANITY
  procthese=$(echo $procthese |sed 's/,,/,/g') # get rid of multiple commas JIC
  procthese=$(echo $procthese |sed 's/ //g') # get rid of spaces
    
# self-shortening loop, like bash "shift"
  stopafterme=0
  maxvmnum=${#vmlist[@]} # of elements in array
  
  while [ ${#procthese} -gt 0 ]; do
# check length 

    if [ "${procthese:0:1}" = "," ]; then
# if 1st char , skip it and gimme the rest    
#[ $debugg -gt 0 ] && echo "TRIPPED 1stchar comma"
      procthese=${procthese:1}
#    else
#[ $debugg -gt 0 ] && echo "NOTRIP 1stchar comma" 
    fi

    procthisvmnum=${procthese%%,*} # Deletes longest match of $substring from back of $string; 1,3,5 = get 1
[ "$procthisvmnum" = "" ] && failexit 99 "procthisvmnum is blank!"
 
    if [ $procthisvmnum -gt $maxvmnum ]; then
      echo "Invalid VM number $procthisvmnum , outside max running: $maxvmnum" |tee -a $logf
      procthese=$(echo $procthese |sed 's/'$procthisvmnum'//') # take out the bad number
      continue; # next iteration
    fi
    
    vm=${vmlist[$procthisvmnum]} # get name from array
    vm=$(echo $vm |tr -d '"' |awk '{print $1}') # take out quotes and only print name

    stopthis=$(VBoxManage list runningvms |awk '/'$vm'/ {print $2}' |tr -d '{}') # get vm uuid + remove brackets
    stopvm $stopthis #|| break # ran out of VMs / last one left

    [ $stopafterme -gt 0 ] && break;
    
    procthese=$(echo ${procthese#*,*}) # 1,3,5 take out the 1,
    [ $(echo $procthese |grep -c ',') -eq 0 ] && let stopafterme=1 # no more commas, last one
#3,5
  done

else
# Single VM
  vm=${vmlist[$vmn]} # get name from array
  vm=$(echo $vm |tr -d '"' |awk '{print $1}') # take out quotes and only print name

  [ "$vm" = "" ] && failexit 101 "Invalid VM"
  stopthis=$(VBoxManage list runningvms |awk '/'$vm'/ {print $2}' |tr -d '{}') # remove brackets

  stopvm $stopthis
fi

date;

ls -lh $logf

exit;

# 2022.0519 Dave Bechtel
