#!/bin/bash

# Requires qemu guest agent installed in-vm

vmid=$1
qm guest cmd $vmid get-fsinfo

exit;


Example output [JSON]:

[
   {
      "disk" : [
         {
            "bus" : 0,
            "bus-type" : "virtio",
            "dev" : "/dev/vdb1",
            "pci-controller" : {
               "bus" : 6,
               "domain" : 0,
               "function" : 0,
               "slot" : 11
            },
            "target" : 0,
            "unit" : 0
         }
      ],
      "mountpoint" : "/mnt/datastore/datastore1-xfs-400",
      "name" : "vdb1",
      "total-bytes" : 482946826240,
      "type" : "xfs",
      "used-bytes" : 320063262720
   },
   {
      "disk" : [
         {
            "bus" : 0,
            "bus-type" : "virtio",
            "dev" : "/dev/vda3",
            "pci-controller" : {
               "bus" : 6,
               "domain" : 0,
               "function" : 0,
               "slot" : 10
            },
            "target" : 0,
            "unit" : 0
         }
      ],
      "mountpoint" : "/",
      "name" : "dm-1",
      "total-bytes" : 17918504960,
      "type" : "ext4",
      "used-bytes" : 4534677504
   }
]

