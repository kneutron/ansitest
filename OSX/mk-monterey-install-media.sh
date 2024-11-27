#!/bin/bash

# Make bootable MacOS / OSX 12.7 install media
# REF: https://krypted.com/mac-os-x/create-bootable-installation-media-high-sierra-installations/
# REF: https://osxdaily.com/2022/02/23/make-macos-monterey-boot-install-drive/

# NOTE usb media must be pre-erased and mounted at /Volumes/macosinstall
# Use Disk Utility, Erase, Mac OS Extended Journaled, GUID partition
# NOTE monterey needs 16GB

source ~/bin/failexit.mrg

[ $(df |grep -c /Volumes/macosinstall) -gt 0 ] || failexit 40 "/Volumes/macosinstall not mounted/found - need to have pre-formatted USB mounted"

#cd ~/Downloads && \
set -x
cd /Volumes/Monterey-Latest-App && \
cd "Install macOS Monterey.app" && \
Contents/Resources/createinstallmedia \
  --volume /Volumes/macosinstall  --nointeraction
