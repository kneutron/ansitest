#!/bin/bash

echo EDITME

exit;

mdadm /dev/md0 --add /dev/sdcX

mdadm /dev/md0 --fail /dev/sdX5 --remove /dev/sdX5
