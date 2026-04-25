#!/bin/bash

# TODO EDITME
ansible all --become -m fetch -a "src=/etc/chrony.conf dest=/home/dave"

# fetch will put file fromeach instance in e.g. dest/servername/etc/chrony.conf		dir tree
