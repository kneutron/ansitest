#!/bin/bash

# this is for when the zfs pool was created / imported commandline and GUI does not detect it

# xxx TODO EDITME or use $1 / $2
pvesm add zfspool zfs2nvme -pool znvme

# zfs2nvme = proxmox name you want displayed in gui
# znvme = actual zpool name
 
