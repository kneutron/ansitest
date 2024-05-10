#!/bin/bash

# running from cron, we need this
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

pveam update
pveam list local # storage name

# useful if we downloaded a 3rd-party template
