#!/bin/bash

# kneutron 2025.Sep

# find / delete video files that were created at night
# REF: https://www.reddit.com/r/mac/comments/1nhv6el/script_delete_files_based_on_time_of_day/

# Linux version

cd /usr || exit 99;

for fyl in $(find * -type f -print); do \
 hourr=$(stat -c %n'&'%y "$fyl" |tr '&' '\t' \
 |awk '{print $3}' |awk -F: '{print $1}'); \
[ $hourr -ge 20 ] || [ $hourr -lt 9 ] && \
 echo  -e "$PWD/$fyl \tDELME \t$hourr"; \
done |head |column -t

exit;


Breakdown:
find files in thisdir, print name, stat name'&'time of last Modification (human-readable); change '&' to tab for output
 Note: if Birth field is populated, should use that instead ( stat -c %n'&'%w ) -- Not all FS track Birth

3rd field is time HH:MM:SS, 1st field of time is hour
"bin&2025-09-14 11:34:08.376055876 -0600"
 1   2          3
    |           1
    ((becomes tab))
                
If hour is >= 20 (8pm) or hour falls between 0 and 8 (midnight / 8am),
 print full dir+filename, tab, DELME, tab, hour 

NOTE - Prints only, does not delete! Run results thru loop + ' rm -v ' after checking

NOTE - add -mtime +7 to find, for limit = files more than a week old


Example output:

/usr/bin/ppmchange           DELME  08
/usr/bin/tsk_imageinfo       DELME  00
/usr/bin/ppmtoicr            DELME  08
/usr/bin/dig                 DELME  03
/usr/bin/dh                  DELME  07
/usr/bin/pnmtorle            DELME  08
/usr/bin/bash                DELME  08
/usr/bin/rrdcached           DELME  05
/usr/bin/dh_link             DELME  07
/usr/bin/dh_installtmpfiles  DELME  07


stat bin/ppmchange

  File: bin/ppmchange
  Size: 14280           Blocks: 32         IO Block: 4096   regular file
Device: 252,1   Inode: 1748969     Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-02-20 13:03:23.000000000 -0700
Modify: 2023-01-11 08:30:00.000000000 -0700
Change: 2024-02-20 13:03:35.445045318 -0700
 Birth: 2024-02-20 13:03:34.085048227 -0700
