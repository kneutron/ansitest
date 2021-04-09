#!/bin/bash5

VBoxManage list --long -s vms |egrep 'Name:|Config file:' |egrep -v 'Snap|Filter' |paste - -
