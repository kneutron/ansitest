#!/bin/bash

df -h
zfs create -o atime=off zmirpool1/dv; chown daveb /zmirpool1/dv
zfs create -o compression=lz4 -o atime=off zmirpool1/dv/compr; chown daveb /zmirpool1/dv/compr

zfs create -o atime=off zpoolraidz2/dv; chown daveb /zpoolraidz2/dv
zfs create -o compression=lz4 -o atime=off zpoolraidz2/dv/compr; chown daveb /zpoolraidz2/dv/compr

zfs create -o atime=off zsepdata1/dv; chown daveb /zsepdata1/dv
zfs create -o compression=lz4 -o atime=off zsepdata1/dv/compr; chown daveb /zsepdata1/dv/compr

df -h


exit;

# zfs create -o mountpoint=/home -o atime=off bigvaiterazfs/home
# zfs create -o mountpoint=/mnt/bigvai500 -o atime=off bigvaiterazfs/dv/bigvai500

# zfs create -o compression=off -o atime=off \
 -o mountpoint=/mnt/bluraytemp25 -o quota=25G bigvaiterazfs/bluraytemp; chown dave /mnt/bluraytemp25

localinfo.dat--b4-restore-2014-0710:bigvaiterazfs/bluraytemp      26214400        128  26214272   1% /mnt/bluraytemp25
localinfo.dat--b4-restore-2014-0710:# time (dd if=/dev/zero of=/mnt/bluraytemp25/bdiscimage.udf bs=2048 count=25025314814;sync)
localinfo.dat--b4-restore-2014-0710:dd: writing `/mnt/bluraytemp25/bdiscimage.udf': Disk quota exceeded

localinfo.dat--b4-restore-2014-0710:# zfs set quota=25.1G bigvaiterazfs/bluraytemp
localinfo.dat--b4-restore-2014-0710:# time (dd if=/dev/zero of=/mnt/bluraytemp25/bdiscimage.udf bs=2048 count=24220008448;sync)
localinfo.dat--b4-restore-2014-0710:dd: writing `/mnt/bluraytemp25/bdiscimage.udf': Disk quota exceeded

localinfo.dat--b4-restore-2014-0710:NOT: # truncate -s 25GB /mnt/bluraytemp25/bdiscimage.udf
localinfo.dat--b4-restore-2014-0710:# truncate -s 23.3GB /mnt/bluraytemp25/bdiscimage.udf
localinfo.dat--b4-restore-2014-0710:# zfs set quota=23.5G bigvaiterazfs/bluraytemp # DONE
localinfo.dat--b4-restore-2014-0710:# cd /mnt/bluraytemp25 && truncate -s 23652352K bdiscimage.udf
localinfo.dat--b4-restore-2014-0710:# cd /mnt/bluraytemp25 && mkudffs --vid="BRTESTBKP20131214" bdiscimage.udf

localinfo.dat--b4-restore-2014-0710:# mount -t udf -o loop /mnt/bluraytemp25/bdiscimage.udf /mnt/bluray-ondisk -onoatime




