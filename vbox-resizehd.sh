#!/bin/bash

time VBoxManage modifyhd $1.vdi --resize $2 # size in MB

