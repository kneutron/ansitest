#!/bin/bash

# Make bootable MacOS / OSX 14.7.2 install media
# REF: https://support.apple.com/en-us/101578
# REF: https://osxdaily.com/2022/02/23/make-macos-monterey-boot-install-drive/

# NOTE usb media must be pre-erased and mounted at /Volumes/macosinstall
# Use Disk Utility, Erase, Mac OS Extended Journaled, GUID partition
# NOTE monterey needs 16GB

source ~/bin/failexit.mrg

#[ $(df |grep -c /Volumes/macos-sonoma14-bootable-installer) -gt 0 ] || failexit 40 "/Volumes/macos-sonoma14-bootable-installer not mounted/found - need to have pre-formatted USB mounted"
[ $(df |grep -c "/Volumes/Install macOS Sonoma") -gt 0 ] || failexit 40 "/Volumes/macos-sonoma14-bootable-installer not mounted/found - need to have pre-formatted USB mounted"

#cd ~/Downloads && \
# where the installer lives - currently on 32GB sdcard
set -x
#cd /Volumes/macos-sonoma-14-installer && \
#cd /Users/dave2/Downloads/ && \
cd /Applications && \
cd "Install macOS Sonoma.app" && \
Contents/Resources/createinstallmedia \
  --volume "/Volumes/Install macOS Sonoma"  --nointeraction
#  --volume /Volumes/macos-sonoma14-bootable-installer  --nointeraction

date;

#Sonoma sudo 
#/Applications/Install\ macOS\ Sonoma.app/Contents/Resources/createinstallmedia --volume /Volumes/MyVolume
