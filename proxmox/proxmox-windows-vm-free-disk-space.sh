#!/bin/bash

# REF: https://forum.proxmox.com/threads/determining-free-disk-space-on-windows-vms.145730/#post-656958

[ $(which jq |wc -l) -eq 0 ] && apt install -y jq

# either one works
#qm agent $1 get-fsinfo \
# |jq '[.[] | select(.["total-bytes"]) | {total_gb: ((.["total-bytes"] / (1024 * 1024 * 1024)) | round), used_gb: ((.["used-bytes"] / (1024 * 1024 * 1024)) | round), free_gb: (((.["total-bytes"] - .["used-bytes"]) / (1024 * 1024 * 1024)) | round)}]'

qm guest cmd $1 get-fsinfo \
 |jq '[.[] | select(.["total-bytes"]) | {total_gb: ((.["total-bytes"] / (1024 * 1024 * 1024)) | round), used_gb: ((.["used-bytes"] / (1024 * 1024 * 1024)) | round), free_gb: (((.["total-bytes"] - .["used-bytes"]) / (1024 * 1024 * 1024)) | round)}]'

date

exit;

