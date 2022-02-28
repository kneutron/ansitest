#!/bin/bash

# if we have a "hanging" flist with no corresponding tar, del

debugg=0

if [ $debugg -gt 0 ]; then
 echo "$(date) Running flist 1st JIC"
 time flist
fi

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

todel=/tmp/todel-flist.txt
>$todel # clearit

declare -i fl tr # integer
fl=$(ls flist* |wc -l |awk '{print $1}')
tr=$(ls *tar* |grep -v flist |wc -l |awk '{print $1}')
echo "Flists: $fl -- Tars: $tr"
[[ $fl == $tr ]] && failexit 0 "Flists match tars, all OK"

# regular array
declare -a flists=$(ls flist*)

for c in ${flists[@]}; do
  proc1=$(basename $c .txt) # strip .txt from end
  proc2=${proc1:7} # easy strip flist--
  if [ $debugg -gt 0 ]; then
    [ -e $proc2.tar* ] && echo "MATCH $c" || echo "NOTMATCH $c"
  fi
#  [ -e $proc2.tar* ] || echo "NOTMATCH $c"
  [ -e $proc2.tar* ] || echo "$c" >> $todel
done

echo "$(wc -l $todel) - hanging FLIST files to delete - Enter to process NON-INTERACTIVELY or ^C"
read

while read inline; do
  [ "$inline" = "" ] && break
  ls -l "$inline" |awk '{print "Size:"$5" Date: "$6" "$7" "$8" "$9}' #|column -t
  /bin/rm -v "$inline"
done < $todel
# for some reason RM -i not working :(

# Cleanup 
# /bin/rm $todel

exit;


NOTE MAC OSX wc -l also prints filename, thats why we need 1st field only!

REF: https://tldp.org/LDP/abs/html/string-manipulation.html

la|awk '{print "Size:"$5" Date: "$6" "$7" "$8" "$9}' |column -t

Size:35077        Date:  Jan  15  11:12  flist--bkp-home-dave-test-p2300m-deepin-sda6.txt

basename bkp-home--NORZ--p2300m-ultimate--20200626.tar1.tar .tar1.tar
bkp-home--NORZ--p2300m-ultimate--20200626

missing tar: 	flist--bkp-home--fryserverantix19--NORZ--20210303.txt
matches:	flist--bkp-home-p2300m-deepin-sda6.txt
		01234567
		
