#!/bin/bash

# 2024.Sep kneutron

# REQUIRES ncurses-bin webp detox (macports / brew)
# NOTE can still convert BAD images using rt-click, Quick Actions, Convert image in Finder!

stime=$(date)

#[ $(which dwebp |wc -l) -gt 0 ] && sudo apt-get install -y webp
#[ $(which detox |wc -l) -gt 0 ] && sudo apt-get install -y detox

# need to cd source 1st
outdir=$HOME/tmpdel-photos/webp2png
mkdir -pv "$outdir"
mkdir -pv $HOME/tmpdel-photos/BAD

cd ~/tmpdel-photos/ || exit 99;
pwd
detox -v $PWD
find ~/tmpdel-photos/ -iname \*'(1)'\* -print -delete

# print blank lines
clear
#for L in 1 2 3 4 5; do echo ""; done
#origpos=$(tput sc) # save current cursor pos, 5 lines down

skip=0
done=0
for f in *.webp; do
  if [ -e "$outdir/$f.png" ]; then
    ((skip++))
#    tput cuu 2 # up 2 lines
#    tput home
    
# Only every 5! speedup - check modulo
# REF: https://unix.stackexchange.com/questions/423389/compare-bash-variable-to-see-if-divisible-by-5
    remainder=$(( skip % 5 ))
    if [ "$remainder" -eq 0 ]; then
      tput home
      echo -n "SKIP = $skip"
      tput el # erase to EOL
#    echo -n "SKIP $f = $skip"; tput el # erase to EOL
      echo ""; tput el; tput rc
    fi
  else
    tput home
    tput cud 1 # down 1 line to not overwrite skip
    echo -n "Processing $f = $((++done))"; tput el
    time dwebp "$f" -o "$outdir/$f.png" 2>>~/webp2png-err.log || ( mv -v $f BAD/; ((done--)) ) # subtract if processing failed
    tput el #; tput rc
  fi
done
# dwebp -mt # may be buggy code

tput home
echo -n "TOTAL SKIP = $skip"
tput el # erase to EOL

ls -alrth "$outdir" |tail
echo "BEGIN = $stime -- $(date) -- DONE= $done / Skip= $skip"

#rsync-tmpdel-to-xrdp.sh
exit;

# REF: https://stackoverflow.com/questions/55161334/convert-webp-images-to-png-by-linux-command
 
# REF: https://linuxcommand.org/lc3_adv_tput.php
 