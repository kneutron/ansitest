#!/bin/bash

VBoxManage list --long -s vms |egrep 'Name:|Config file:' |egrep -v 'Snap|Filter' |paste - -
# Note GUI setting = rt-click on right pane, General / Location √
