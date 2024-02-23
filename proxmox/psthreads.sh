#!/bin/bash

# show subthreads and grep for $thing
# 2024.feb kneutron
# Useful if you want to assign specific cores to VM + cpu-using subthreads

# example usage: $0 zstd
# $0 vmid

ps -eLf |head -n 1
ps -eLf --columns $COLUMNS |grep "$@" |egrep -v 'grep|bash'

exit;

Example:

$ psthreads.sh 112 # or ' kvm -id 112 ' as shown in ' htop '
UID          PID    PPID     LWP  C NLWP STIME TTY          TIME CMD
root      223474       1  223474 99   11 Feb21 ?        3-02:07:20 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -ch
root      223474       1  223475  0   11 Feb21 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  223477  0   11 Feb21 ?        00:00:43 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  223596 78   11 Feb21 ?        1-12:56:56 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -ch
root      223474       1  223597 77   11 Feb21 ?        1-12:27:49 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -ch
root      223474       1  223606  0   11 Feb21 ?        00:00:05 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  223607  0   11 Feb21 ?        00:03:47 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  665268  0   11 Feb22 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  823112  0   11 05:40 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  899901  0   11 11:03 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char
root      223474       1  900029  0   11 11:03 ?        00:00:00 /usr/bin/kvm -id 112 -name win10-net-iso-install-boinc,debug-threads=on -no-shutdown -char

In this case, you could use ' taskset -cp 6,7 223474; taskset -cp 6 223596; taskset -cp 7 223597 ' 
  to assign the cpu-using process+threads on VM 112 to specific CPU cores 6 + 7 
  
