#!/bin/bash
#smbclient -N -L localhost

# in linux guest:  smbclient -U userid -L hostIP

outfile=/tmp/sharing.txt

zfs get sharesmb |grep ' on ' > $outfile

# REF: https://superuser.com/questions/499075/view-shared-folders-from-terminal
#sharing -l >> $outfile
sharing -l |grep -A 1 smb |grep -v smb >> $outfile

#less $outfile
grep -v '^--' $outfile
