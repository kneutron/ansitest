#!/bin/bash5

# Rename a set of files in current dir from .csv - portable and fairly simple
# 2022.Dec Kingneutron

# HOWTO: 
# cd to dir you want to work on
# Populate a temporary file with bare filenames (don't have to use ls, can use "find" or whatever)
# ls -1 >tmp.csv 	

# Preprocess tmp file and add comma + duplicate filename:
# awk '{print $1",\t"$1}' tmp.csv |column -t >rename.csv

# Edit tmp file and replace 2nd filename after comma with preferred filename
# IMPORTANT: Delete any lines that you DONT want renamed

# Run this script

# failexit.mrg
# REF: https://sharats.me/posts/shell-script-best-practices/
function failexit () {
  echo '! Something failed! Code: '"$1 $2" >&2 # code (and optional description)
  exit $1
}

# xxx TODO EDITME
infile=rename.csv
[ -e $infile ] || failexit 44 "$infile not found in $PWD"

logf=$HOME/ren-from-csv.log
date >>$logf
pwd >>$logf

errlog=$HOME/ren-from-csv-errs.log
>$errlog # clearit

OIFS=$IFS
IFS="
"

#set -x # DEBUGG
while read inputline; do
  f2r=$(echo "$inputline" |awk -F',' '{print $1}')
  rento=$(echo "$inputline" |awk -F',' '{print $2}' |sed 's/ //g') # no spaces

  /bin/mv -v "$f2r" "$rento" >>$logf 2>>$errlog
done < $infile
IFS=$OIFS

echo "DONE - $(date)" >>$logf
ls -lh $logf $errlog

exit;

# PROTIP: install detox package and run that on dir 1st 	# detox -v $PWD

# HOWTO:
# $ ls -1 >tmp.csv # populate
wallpapersden.com_olivia-taylor-dudley-2018_2160x3840.jpg
watchmen-youre-locked-in-here-with-me--fark_9jLJBkZ86xroJXgJl_PxH0pBQf8.jpg
we-dont-need-no-stinkin-gadgets--fark_mqkB3Y1u50LMlRwXXyDPjOkwltw.jpg
wunmi-mosaku.jpg
xev-fark_SWJwl7Tm8mZKQydJ60dKAqVJlI0.jpg

# Add comma+tab and Dup to field 2 ++ make easy to read
awk '{print $1",\t"$1}' tmp.csv |column -t >rename.csv
#awk '{print $0",\t"$1}' tmp.csv >rename.csv

$ cat rename.csv 
we-beat-em-before-red-hat-nazis--fark_D0aakxPNV05v8A6OUS2P6AZAYms.jpg,        we-beat-em-before-red-hat-naztis--fark_D0aakxPNV05v8A6OUS2P6AZAYms.jpg
we-dont-need-no-stinkin-gadgets--fark_mqkB3Y1u50LMlRwXXyDPjOkwltw.jpg,        we-dont-need-no-steenkin-gadgets--fark_mqkB3Y1u50LMlRwXXyDPjOkwltw.jpg
wunmi-mosaku.jpg,                                                             wunmi-mosaku-ren.jpg
