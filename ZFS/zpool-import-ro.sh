#!/bin/bash
zpool import -f -o readonly=on "$*"
zpool status -v
