#!/bin/bash

# REF: https://discussions.apple.com/thread/255859460?sortBy=rank
# https://www.macworld.com/article/673697/what-version-of-macos-can-my-mac-run.html

cd ~/Downloads

softwareupdate  --list-full-installers

echo "Enter version"
read instversion

[ "$instversion" = "" ] && exit 99;

# As of Nov 25, 2024 - Monterey
time softwareupdate  -d  --fetch-full-installer  --full-installer-version $instversion # 12.7.6
date
