#!/bin/bash

# 2022 Dave Bechtel
# Utility: Prints ONLY the lines that need to be fixed in a malformed /etc/hosts
# Canonical format: IP FQDN shortname(s)
# Fix malformed line(s): IP short FQDN
# Handles a limited number of extra aliases (up to 5)
# Does NOT modify original /etc/hosts and MAY NOT handle IPv6 (not tested)

infile=/etc/hosts
#infile=/tmp/hosts.test
outfile=/tmp/hosts.fixed
>$outfile #clearit

declare -i checkfq # integer

#set -x ## debugg
while read inline; do
  [ "$inline" = "" ] && continue # blank line
  [ ${inline:0:1} = "#" ] && continue # comment

  fld2=$(echo $inline |awk '{print $2'})
  [ "$fld2" = "localhost" ] && continue # 127.0.0.1 has no longname
  
  checkfq=$(echo $fld2 |awk 'END{print index($0,".")}')
  [ $checkfq -gt 0 ] && continue # dot found, valid line
  
  outline=$(echo "$inline" |awk '{print $1" "$3" "$2" "$4" "$5" "$6" "$7" "$8}')
  echo "$outline" |tee -a $outfile
done <$infile

echo ''
echo '====='
ls -alh $outfile

exit;


# REF: https://unix.stackexchange.com/questions/153339/how-to-find-a-position-of-a-character
$ echo $tmp1;echo $tmp2
nodot
hasdot.fq.dn

$ echo $tmp1 |awk 'END{print index($0,".")}'
0
$ echo $tmp2 |awk 'END{print index($0,".")}'
7

Sample output:

$ time fixetchosts.sh
255.255.255.255  broadcasthost
10.9.28.24 davesimac-2.series.org imacdual imacold oldimacdualcore
192.168.1.4 cubie.series.org cubietruck-wifi pihole
10.9.0.4 cubietruck-devuan.series.org cubietruck-devuan

=====
-rw-r--r--  1 dave  wheel   241B Mar  2 15:42 /tmp/hosts.fixed

real    0m0.139s
