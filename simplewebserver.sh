#!/bin/sh

# Basically serve current dir as browseable over a given port; cd and run
# - needs to run as root in FG (for ports under 1025) and can run unprivileged on e.g. port 8000 if firewall allows
# - need to ^C to kill this
# REF: https://www.perlmonks.org/?node_id=865148
# REF: https://www.w3.org/Daemon/User/Installation/PrivilegedPorts.html#:~:text=Priviliged%20ports,has%20put%20up%20for%20you.

python -m SimpleHTTPServer 80 > ~/simple-web-server.log 2>&1 
date
