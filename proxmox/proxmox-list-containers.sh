#!/bin/bash

# 2024.Apr kneutron

declare -a tmpa
tmpa=$(pct list)
# if we dont quote tha var/array, only get 1 line of output

echo "$tmpa" |egrep 'Status|running'
#VMID       Status     Lock         Name                
#105        running                 gotify              
#118        running                 proxmox-fileserver-ctr

echo '====='
echo "$tmpa" |egrep 'Status|stopped'
#VMID       Status     Lock         Name                
#110        stopped                 suseleap-ctr-p      
#113        stopped                 debian-ctr          
#114        stopped                 debianctr-xorgtest  
#122        stopped                 test-phone-tether   
#124        stopped                 debian-qdevice-dellap

exit;

# echo "$tmpa"
VMID       Status     Lock         Name                
105        running                 gotify              
110        stopped                 suseleap-ctr-p      
113        stopped                 debian-ctr          
114        stopped                 debianctr-xorgtest  
118        running                 proxmox-fileserver-ctr
122        stopped                 test-phone-tether   
124        stopped                 debian-qdevice-dellap
