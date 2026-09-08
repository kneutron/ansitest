#!/bin/sh
# we dont have bash yet

# runme as root

(
# xxx TODO EDITME
primaryuser=dave

# enable community repos and use fastest mir
setup-apkrepos -c -f

# essential pkgs
apk add joe mc screen tmux vim nano bwm-ng sysstat sudo bash parted less curl rsyslog libuser gptfdisk sgdisk

# self-advertise thisbox as $(hostname -s).local 	# mDNS
apk add avahi \
avahi-compat-libdns_sd \
avahi-glib \
avahi-lang \
avahi-libs \
avahi-nftrules \
avahi-static \
avahi-tools \
avahi-ui \
avahi-ui-tools 

rc-update add avahi-daemon
rc-service avahi-daemon start

# fix cron
rc-service crond start && rc-update add crond

#After that the cron daemon is started automatically on system boot and
#executes the scripts placed in the folders under /etc/periodic/ - there are
#folders for 15min, hourly, daily, weekly and monthly scripts.


# iscsi - TODO editme as needed
mkdir -pv /etc/tgt/conf.d
cat <<EOF >/etc/tgt/conf.d/iscsi.conf
# tgt-admin configuration file
## By default, tgt-admin looks for its config file in /etc/tgt/targets.conf

# Set the driver. If not specified, defaults to "iscsi".
default-driver iscsi

## Define a target - set or single
# iSCSI naming convention for iqn format:
# https://www.rfc-editor.org/rfc/rfc3721#section-1.1

<target iqn.2026-09.alpine.iscsi:server.target1>
    ## General settings
    controller_tid 1
    vendor_id AlpineLinux

    ## iSCSI features
    HeaderDigest None
    DataDigest None
    ErrorRecoveryLevel 2
 
    ## Access control - optional
#    initiator-address 172.16.25.153
#    incominguser user1 secretpass12

    ## iSCSI targets (exports)
#    <backing-store "/media/target/diskimage_1.img">
    <backing-store /dev/sdb>
        lun 1
        block-size 4096
        params thin_provisioning=1 rotation_rate=0 sense_format=1
        allow-in-use yes
        write-cache on
        scsi_sn 1001
        product_id rpoolMirror
    </backing-store>
</target>
EOF

# Example iqns:
#iqn.2001-04.com.example:storage:diskarrays-sn-a8675309
#iqn.2001-04.com.example:storage.tape1.sys1.xyz
#iqn.2001-04.com.example:storage.disk2.sys1.xyz
     
# NOTE You can configure multiple backing stores (LUNs) in TGT under
#/etc/tgt/targets.conf by adding multiple backing-store or direct-store
#lines inside a single <target> block.

#<target ://2026-09.com.example:storage.disk1>
    # LUN 1: Direct-mapped block device
#    direct-store /dev/sdb

    # LUN 2: Standard block device backing store
#    backing-store /dev/disk/by-id/lvm-vg-lv_data

    # LUN 3: File-backed storage
#    backing-store /var/lib/iscsi_disks/disk3.img

    # Optional: Restrict access to a specific initiator
#    initiator-address 192.168.1.50

    # Optional: chap Authentication
#    incominguser myuser securepassword123
#</target>


#    vendor_id Forza
#        product_id MediaFiles

#[421972.649553] scsi host2: iSCSI Initiator over TCP/IP
#[421972.658734] scsi 2:0:0:0: RAID              IET      Controller       0001 PQ: 0 ANSI: 5
#[421972.668589] scsi 2:0:0:0: Attached scsi generic sg1 type 12
#[421972.671131] scsi 2:0:0:1: Direct-Access     Forza    MediaFiles       0001 PQ: 0 ANSI: 5
#[421972.682988] scsi 2:0:0:1: Attached scsi generic sg2 type 0

ls -lh /etc/tgt/conf.d

apk add scsi-tgt scsi-tgt-scripts
rc-update add tgt-admin
service tgt-admin start

# verify
echo '====='
tgtadm --mode target --op show

#tgt-admin is a convenience script to configure the running tgtd daemon. It is not needed if you want to manually configure tgtd using the tgtadm tool.
#Documentation can be found in the scsi-tgt-doc package (man tgt-admin), but also on upstream's GitHub page
#
#Common tgt-admin commands are:
#
#    tgt-admin --execute
#
#Load new targets from /etc/tgt/targets.conf. Existing targets won't be updated.
#
#    tgt-admin --update <value>
#
#Update selected targets. Targets in-use by initiators won't be updated.
#
#    tgt-admin --show
#
#Query tgtd for running configuration.
#
#    tgt-admin --pretend
#
#Only print what would be done and not make any changes.
#tgt-admin examples
#
#To see the status of the running configuration, use the tgt-admin -s command:

#echo '====='
#tgt-admin -s		# Skip, shows same info

# If you want to see that native commands are needed you can use the --verbose option. 


# man pages:
# The docs meta package will immediately install the documentation
# sub-package for all of the currently installed packages (plus the mandoc
# reader, if not installed).  docs additionally ensures that documentation
# sub-packages are installed/removed automatically for any packages that one
# may add/remove in the future.

apk add docs

mkdir -pv $HOME/bin/boojum $HOME/tmpdel

useradd "$primaryuser"
usermod -aG wheel "$primaryuser"
) 2>~/freshinstall-alpine-errs.log

echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers

# REF: https://wiki.alpinelinux.org/wiki/Alpine_Linux:FAQ

#==================

# HOWTO Connecting the Initiator to the Target (Linux)

#From the iSCSI initiator, first run this command:

# iscsiadm --mode discovery --type sendtargets --portal IP_OF_TARGET

#This command contacts the target to determine which disks are available.  If
#all is configured correctly, the target name
#  iqn.2006-01.com.example:disk2.vol1 
#(from the example above) will be returned.

#After the target is discovered, run this command to connect:

# iscsiadm --mode node --targetname NAME_OF_TARGET --portal IP_OF_TARGET --login

# NOTE Replacing --login with --logout will end the connection.

#To make this connection persistent (so that it will reconnect after reboot), run this command:

# iscsiadm -m node -T NAME_OF_TARGET -p IP_OF_TARGET --op update -n node.conn[0].startup -v automatic

# REF: https://wiki.alpinelinux.org/wiki/Setting_up_iSCSI

#When you expand the volume or disk, you might need to rescan. So the below command will help:

# iscsiadm -m node -p <ipaddress> --rescan

# also possible to login to all the available targets with -L:

# iscsiadm --mode node --portal <ip> -L
