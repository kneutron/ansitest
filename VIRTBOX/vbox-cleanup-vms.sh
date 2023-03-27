#!/bin/bash5

# useful if backing store changed, get rid of inacc vms

# vbm unregistervm  <uuid|vmname>
vmallfile=/tmp/vbox-allvms.txt
#vmrunningfile=/tmp/vbox-running.txt

debugg=0 
vbm=VBoxManage

logfile=$HOME/vbox-unregistered-vms.log

# failexit.mrg
# REF: https://sharats.me/posts/shell-script-best-practices/
function failexit () {
  echo '! Something failed! Code: '"$1 $2" >&2 # code (and optional description)
  exit $1
}

# define array
declare -a vmlist
declare -a runningvms

vmlist=$($vbm list vms |grep inaccessible |tr -d '<>{}\"' |column -t)
#"<inaccessible>" {e54ed6b4-c464-46a7-9d34-8c429b932edc}
#inaccessible  e54ed6b4-c464-46a7-9d34-8c429b932edc

#dummyisofinder                                     e15815e6-6be7-4628-9093-bbadbf4ec6f7

#echo "All VMs"
#echo "$vmlist" |tee $vmallfile
echo "$vmlist" > $vmallfile

runningvms=$($vbm list runningvms |tr -d '{}\"' |column -t)
echo "o Running: "
echo "$runningvms" |tee $vmrunningfile

cat $vmallfile
echo "Found these vms that need to be cleaned up - PK or ^C"
read

declare -i result=0
# REF:https://www.virtualbox.org/ticket/17215
while read vmname vmuuid; do
  echo "Vmname $vmname - UUID $vmuuid"
  
  result=$(grep -c $vname $vmrunningfile) 2>/dev/null
  if [ $result -gt 0 ]; then 
    echo "VM already running"
  else
		echo "$(date) - Unregistering ${vmuuid} as inacessible" |tee -a $logfile
		
		$vbm unregistervm ${vmuuid} || failexit 101 "Failed to unregister $vmuuid"
	fi
	# call external bin
done < $vmallfile

date
echo "Recommended to run vb-discover-virtmachines.sh and vb-registerISOs.sh now"
