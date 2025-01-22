#!/bin/bash

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# xxx TODO EDITME
dest=/Volumes/zmac5int/zmac5intcompshr

cd $dest || failexit 101 "check $dest"

time hdiutil create -o HighSierra.cdr -size 6000m -layout SPUD -fs HFS+J && \
  hdiutil attach HighSierra.cdr.dmg -noverify -mountpoint /Volumes/install_build

sudo $HOME/Downloads/Install\ macOS\ High\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/install_build

mv -v HighSierra.cdr.dmg HighSierra.dmg

hdiutil detach /Volumes/Install\ macOS\ High\ Sierra
hdiutil detach /Volumes/install_build

time hdiutil convert HighSierra.dmg -format UDTO -o HighSierra.iso && mv -v HighSierra.iso.cdr HighSierra.iso
date
ls -alh *.iso
