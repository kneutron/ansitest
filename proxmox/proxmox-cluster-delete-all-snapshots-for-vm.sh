#!/bin/bash

# REF: https://forum.proxmox.com/threads/feature-request-button-to-delete-all-snapshots-at-once.147460/#post-666313

# Cluster version - delete all snapshots for a vm
# NOTE this also works on unclustered instances of pve

# Thanks to original author bbgeek17
# enhanced by kneutron

# USE AT YOUR OWN RISK - I TAKE NO REPSONSIBILITY FOR DATA LOSS!

# Depends: jq
[ $(which jq |wc -l) -eq 0 ] && apt install -y jq

# arg1 = vmid
if [[ $# -lt 1 ]];then
  echo "You must provide a parameter!"
  echo "USAGE: $0 [VMID]"
  exit 1
fi

logf=~/deleted-snapshots-cluster.log

set -u # abort on undefined var

echo "$(date) - Gathering information"
echo '=========='
VMID=$1
NODE=$(pvesh get /cluster/resources --type vm --output-format json \
 |jq --argjson myvmid $VMID -r '.[]|select( .vmid == $myvmid )|.node')

# show vm info
(pvesh get /cluster/resources --type vm --human-readable 1 --noborder 1 |egrep "cgroup|$1") |column -t

# TODO test for interactive session
echo '=========='
echo "About to removw ALL snapshots from VM $VMID located on node $NODE - ^C to back out or Enter to proceed"
read

for snap in $(pvesh get /nodes/$NODE/qemu/$VMID/snapshot --output-format json \
 |jq -r 'sort_by(.snaptime)|.[]|select(.snaptime != null)|.name'); do
   echo "$(date) - $(id -un) - $VMID on $NODE - $snap" \
     |tee -a $logf
   time pvesh delete /nodes/$NODE/qemu/$VMID/snapshot/$snap
done

date
