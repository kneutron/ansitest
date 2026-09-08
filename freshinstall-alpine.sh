#!/bin/sh
# we dont have bash yet

(
# enable community repos and use fastest mir
setup-apkrepos -c -f

# essential pkgs
apk add joe mc screen tmux vim nano bwm-ng sysstat sudo bash parted less curl rsyslog libuser gptfdisk sgdisk

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

## Define a target
# iSCSI naming convention for iqn format:
# https://www.rfc-editor.org/rfc/rfc3721#section-1.1

<target iqn.2026-09.alpine.iscsi:server.target1>
    ## General settings
    controller_tid 1
    vendor_id Forza

    ## iSCSI features
    HeaderDigest None
    DataDigest None
    ErrorRecoveryLevel 2
 
    ## Access control
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
        product_id MediaFiles
    </backing-store>
</target>
EOF

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

echo '====='
tgt-admin -s

# If you want to see that native commands are needed you can use the --verbose option. 


# man pages:
# The docs meta package will immediately install the documentation
# sub-package for all of the currently installed packages (plus the mandoc
# reader, if not installed).  docs additionally ensures that documentation
# sub-packages are installed/removed automatically for any packages that one
# may add/remove in the future.

apk add docs

mkdir -pv $HOME/bin/boojum $HOME/tmpdel

useradd dave
usermod -aG wheel dave
) 2>~/freshinstall-alpine-errs.log

echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers

# REF: https://wiki.alpinelinux.org/wiki/Alpine_Linux:FAQ
