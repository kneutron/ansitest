#!/bin/bash

cmd="date"
ansible rhel8 -a "$cmd"
echo '-----'
ansible rhel9 -a "$cmd"
echo '-----'
ansible debian -a "$cmd"

date;


