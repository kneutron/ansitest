#1/bin/bash

date
time VBoxManage modifymedium disk "$1" --resize "$2"
date
