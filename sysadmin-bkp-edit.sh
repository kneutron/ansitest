#!/bin/bash

# Backup critical file before editing (in current dir)
# 2024.Mar kneutron

cp -v "$1" "$1".bkp.$(date +%Y%m%d@%H%M%S)

ls -lh "$1*"
echo "Backed up $1 - OK to edit - Press enter"
read -n 1

$EDITOR "$1"
