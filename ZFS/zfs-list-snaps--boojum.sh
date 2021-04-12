#!/bin/bash

# REF: https://pthree.org/2012/12/19/zfs-administration-part-xii-snapshots-and-clones/
zfs list -r -t snapshot -o name,used,refer,mountpoint,creation
