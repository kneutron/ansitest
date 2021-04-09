#!/bin/bash

# Discover existing virtualbox vms and add them to the GUI
# If GUI is already running, they should populate in realtime

# REF: https://www.virtualbox.org/manual/ch08.html#vboxmanage-general

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

vbm=$(which VBoxManage)

function discregis () {
  find .  -name *.vbox -type f -exec $vbm registervm "$PWD/{}" \;
}

# xxx TODO EDITME put your VM directory here
cd /Volumes/zsgtera4/virtbox-virtmachines || failexit 101 "! Cannot cd to VM dir"
discregis

# 2ndary VM dir
#cd /zdell500/virtbox-virtmachines || failexit 102 "! Cannot cd to VM dir"
#discregis


VBoxManage list vms

echo "PK to call vb-registerISOs.sh, or ^C to skip"
read -n 1
vb-registerISOs.sh

exit;

# 2021 Dave Bechtel