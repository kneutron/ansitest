#!/bin/bash5

result=$(VBoxManage list vms)

# do it by GUID
for vm in $( VBoxManage list vms |awk '{print $2}' |tr -d '{}'); 
  do echo "$result" |grep $vm 
  VBoxManage snapshot $vm list --machinereadable
  echo ''
done

exit;

"centos7-testvm-LVMpartresize" {7ed11c65-9fa2-43b2-811e-6295f172506c}
SnapshotName="Snapshot 4 - b4 script"
SnapshotUUID="1c8013c2-fe09-46ae-b6fd-415038315511"
SnapshotName-1="Snapshot - wiped btrfs on sdb3 and fixed vgname"
SnapshotUUID-1="d51d5f42-0353-4ed3-841a-e7de66061c1e"
SnapshotName-1-1="Snapshot - wiped btrfs on b3, fixed swap uuid"
SnapshotUUID-1-1="c449b5de-96a0-4e66-b6f1-6d3f842f19b1"
SnapshotName-1-1-1="Snapshot - finalizing code, b4 script run"
SnapshotUUID-1-1-1="3f1da271-da20-44ed-9d1c-33aa9bcb50e4"
SnapshotName-1-1-1-1="Snapshot - finalizing code"
SnapshotUUID-1-1-1-1="cd2a4d75-3754-4aab-8b8d-d2a361f1d456"
CurrentSnapshotName="Snapshot - finalizing code"
CurrentSnapshotUUID="cd2a4d75-3754-4aab-8b8d-d2a361f1d456"
CurrentSnapshotNode="SnapshotName-1-1-1-1"

"p2v-imac5-ubuntu1804firewire" {39d78e39-3d04-486e-a61d-10a7e4755657}
This machine does not have any snapshots
