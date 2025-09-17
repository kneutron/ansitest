#!/usr/bin/env bash5 

# kneutron 2025.Sep

# find / delete video files that were created at night
# REF: https://www.reddit.com/r/mac/comments/1nhv6el/script_delete_files_based_on_time_of_day/

# Mac version (Sonoma 14)

# proof of concept
cd /tmp || exit 99;

 mkdir -pv 1/2
 cd 1
 for f in {1..5}; do touch $f; done
# forward the timestamp by +HHMMSS, not absolute timestamp - only for file '3'
 touch -A 020000 3
 stat -x *

#--Right now the example set of files was created at 19:xx, with only file 3 touched to be 8pm

for fyl in $(find * -type f -print); do \
 hourr=$(stat -f "%N&%Sm" "$fyl" |tr '&' '\t' |awk '{print $4}' \
 |awk -F: '{print $1}'); \
 [ $hourr -ge 20 ] || [ $hourr -lt 9 ] \
 && echo  -e "$PWD/$fyl \tDELME \t$hourr"; \
done \
|column -t \
>/tmp/files-to-delete.txt

exit;

#========================


# Output:
/tmp/1/3  DELME  21

Redirect this output to a file ( /tmp/files-to-delete.txt ) , and you will get a report on which files should be deleted.

You should look over this report to see if there are any erroneous files that you want to keep, and edit + delete those line(s).

Breakdown: find files in this directory, stat Name with a replaceable
character "&" (that will become a tab with the 'tr' call) and the
Modification time, print the time (field 4) and grab only the first field
before ":", this is the Hour.  If hour is greater than or = to 20, or hour
is 0-9, print name of file, DELME, and hour.

Run this report output through a simple loop and print the first field, pipe
it to ' rm -v ' and it should delete it.  

NOTE - If Birth time is populated, should probably use that instead:
 stat -f "%N&%SB"

Add -mtime 7d 	to find files more than a week old 

Run this report output through a simple loop and print the first field, pipe
it to ' rm -v ' and it should delete it. Running through xargs or parallel
is left as an exercise for the reader. 

You can comma-separate it in the last "echo -e" if you want to make it a .csv 
and load it into a spreadsheet for convenience / tracking.

from man stat:

            a, m, c, B
                     The time file was last accessed or modified, or when the inode was last changed, or the birth time of the inode (st_atime, st_mtime, st_ctime, st_birthtime).

from man touch:

     -A      Adjust the access and modification time stamps for the file by the specified value.  This flag is intended for use in modifying files with incorrectly set time stamps.

             The argument is of the form [-][[hh]mm]SS where each pair of letters represents the following:

                   -       Make the adjustment negative: the new time stamp is set to be before the old one.
                   hh      The number of hours, from 00 to 99.
                   mm      The number of minutes, from 00 to 59.
                   SS      The number of seconds, from 00 to 59.
