#!/bin/bash

for zds in $(df|grep '.zfs' |awk '{print $1}'); do
  zfs umount $zds
done

df -hT

exit;

zmacsg2t/virtbox-virtmachines@boojumDOM06
zmacsg2t/virtbox-virtmachines@Wed
zmacsg2t/virtbox-virtmachines@boojumDOM10
zmacsg2t/virtbox-virtmachines@Sun
zmacsg2t/virtbox-virtmachines@boojumDOM16
zmacsg2t/virtbox-virtmachines@Sat
