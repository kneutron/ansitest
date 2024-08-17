#!/bin/bash

# 2024.Aug kneutron

# Feature - parallel process if # of VMs is > 15
# Feature - now works with either VM / CTR VMID

# REQUIRES: parallel awk grep

# arg1 = vmid
if [ "$1" = "" ]; then
# list all; 
  echo "$(date) - Listing all VM snapshots"
# xxx TODO EDITME - change this if you favor CTR count over VMs
#  if [ $(pct list |wc -l) -gt 15 ]; then
  if [ $(qm list |wc -l) -gt 15 ]; then
#  DONE parallel to sep tmp files, sort and cat
  
# create list of VM IDs on thisnode
    tmpdir=/dev/shm
    vmlistf=$tmpdir/vmlist.infile
    ctrlistf=$tmpdir/ctrlist.infile
  
    para=/usr/bin/parallel
# REF: https://stackoverflow.com/questions/22187834/gnu-parallel-output-each-job-to-a-different-file
    [ -e $para ] || apt-get install -y parallel

# auto cleanup
    /bin/rm -f $tmpdir/proxmox-snaplist* "$vmlistf" "$ctrlistf"
  
# populate
    echo "$(date) - Getting list of VMs"
    qm list |grep -v VMID |awk '{print "qm listsnapshot "$1}' > "$vmlistf"
 
    echo "$(date) - Getting list of CTRs"
    pct list |grep -v VMID |awk '{print "pct listsnapshot "$1}' > "$ctrlistf"
    
    limitt=5
    cd $tmpdir
  
    echo "$(date) - Processing VM list in parallel"
    time cat $vmlistf |$para  -j $limitt --results proxmox-snaplist-{}.out 
    date
 
    echo "$(date) - Processing CTR list in parallel"
    time cat $ctrlistf |$para  -j $limitt --results proxmox-snaplist-{}.out 
    date
  
# show filename
    tail -n +1 proxmox-snaplist-pct*.out #|less
    tail -n +1 proxmox-snaplist-qm*.out #|less
      
  else
    for vmid in $(pct list |grep -v VMID |awk '{print $1}'); do
      echo "$(date) === CTR VMID: $vmid" 
      pct listsnapshot $vmid 
    done
    for vmid in $(qm list |grep -v VMID |awk '{print $1}'); do
      echo "$(date) === VMID: $vmid" 
      qm listsnapshot $vmid 
    done
  fi
else
# we got passed an arg
  time qm listsnapshot $1 2>/dev/null || time pct listsnapshot $1
fi

# PROTIP: pipe output to awk 'NF>0' to get rid of blank lines

exit;

# REF: https://phoenixnap.com/kb/proxmox-delete-vm#ftoc-heading-9
# qm listsnapshot 126
`-> b4-nic-change               2024-05-02 17:54:37     powered off!
 `-> current                                            You are here!

# to delete snapshot:
# qm delsnapshot [vmid] [snapshot_name]
# pct delsnapshot <vmid> <snapname> [OPTIONS] # for CTR
