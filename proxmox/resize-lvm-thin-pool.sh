#!/bin/bash

#exit;
meta=127M # increase by 10% of new GB

cursize=207 # GB 	# lvs |grep data |awk '{print $4}'
sizeup=127 # GB
let newsize=$cursize+$sizeup

# Use webmin to add PV, then
lvresize --poolmetadatasize +$meta /dev/mapper/pve-data

set -x
time lvresize -L${newsize}G pve/data -r -vvv #--type thin-pool
lvs
