#!/bin/bash

# Author: dave.bechtel kingneutron@gmail , +%Y2022
# Utility script to translate server names to cloud service / physical location and type (sandbox, dev, prod, etc)
# Current version: 1.2 2022.0119.1300
# Requires: bash v3.2.57 or later

# NOTE set to 0 to disable "gt<1 ae<2 scg<3 d<4 01<5" helpful breakdown output
debugg=1
[ $debugg -gt 1 ] && set -e # Exit at first error

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

#echo "** Server Translator -- Author: dave.bechtel kingneutron@gmail **"

# Azure cloud
# 3 chars for location, 3 for app, 3 for function, 2 for environment, 2 for server count
# ex. zgq xym mgm cs 01 == "Azure Gov Qual - Xymon - Management - Customer Services - 01"
#     1   2   3   4  5
zgq="Azure Gov Qual"
zgb="Azure Gov Bensonville"

sb="Sandbox"
de="Development"
np="NonProd"
cs="Customer Services"
pr="Production"
qa="Quality Assurance"

# AWS cloud
# 3 for location, 3 for app, 3 for function, 2 for env, 2 for server count
# ex. aw1 xym mgm ss 01 == "AWS Virginia - Xymon - Management - Shared Services - 01"
aw1="AWS Virginia"

ss="Shared Services"
te="Test"

# On-prem physical / VM
# 2 for location, 2 for app owner, 3 for function, 1 for env, 2 for server count
# Prefixes
ch="Chicago (on-prem)"
sa="San Antonio (on-prem)"

# Appowner
db="Database"
lx="Linux"

# server function
adm="AHE LINUX Gateway"
app="Application"
azs="Replication"
cfj="Confluence / JIRA"
dbe="Database"
dbg="Oracle Dataguard"
gms="Golden Master Server"
mgm="Management"
oem="OEM"
web="Webserver"
xym="XYMon Monitoring"

# Env
s="Sandbox"
d="Development"
t="Test"
q="QA"
p="Production"
h="Training"


#############################
# Functions
function transazure () {
# arg=zgqxymmgmcs01
#               111
#     0123456789012
# Print a helpful breakdown of parts
[ $debugg -gt 0 ] && echo ${arg:0:3}'<1 '${arg:3:3}'<2 '${arg:6:3}'<3 '${arg:9:2}'<4 '${arg:11:2}'<5 '
#zgq<1 xym<2 mgm<3 cs<4 01<5 

  part1=${arg:0:3}
  part2=${arg:3:3}
  part3=${arg:6:3}
  part4=${arg:9:2}
  part5=${arg:11:2}

  case "$part1" in
    zgq )
      buildstr="$arg = $zgq -" ;;
    zgb )
      buildstr="$arg = $zgb -" ;;
  esac

# 1-offs
  case "$part2" in
    bfg )
      buildstr="$buildstr DoomBFG -" ;;
#    xym )
#      buildstr="$buildstr $xym -" ;;
#    oem )
#      buildstr="$buildstr $oem -" ;;
  * )
# Fallthru
# REF: https://unix.stackexchange.com/questions/23111/what-is-the-eval-command-in-bash
# see if section EVALuates to already-defined var, populate if result = not blank

    eval tmptest='$'$part2; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"
  esac
  
#  case "$part3" in
#    dbe )
#      buildstr="$buildstr $dbe -" ;;
#    mgm )
#      buildstr="$buildstr $mgm -" ;;
#  esac

  eval tmptest='$'$part3; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

#  case "$part4" in
#    sb )
#      buildstr="$buildstr $sb -" ;;
#    de )
#      buildstr="$buildstr $de -" ;;
#    np )
#      buildstr="$buildstr $np -" ;;
#    cs )
#      buildstr="$buildstr $cs -" ;;  
#    pr )
#      buildstr="$buildstr $pr -" ;;
#    qa )
#      buildstr="$buildstr $qa -" ;;
#  esac

  eval tmptest='$'$part4; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

  buildstr="$buildstr $part5"
  echo "$buildstr"

exit 0;
}

function transamazon () {
# arg=aw1xymmgmss99
#               111
#     0123456789012
[ $debugg -gt 0 ] && echo ${arg:0:3}'<1 '${arg:3:3}'<2 '${arg:6:3}'<3 '${arg:9:2}'<4 '${arg:11:2}'<5 '
#aw1<1 xym<2 mgm<3 ss<4 01<5 

  part1=${arg:0:3}
  part2=${arg:3:3}
  part3=${arg:6:3}
  part4=${arg:9:2}
  part5=${arg:11:2}

  case "$part1" in
    aw1 )
      buildstr="$arg = $aw1 -" ;;
  esac

#  case "$part2" in
#    adm )
#      buildstr="$buildstr $adm -" ;;
#    xym )
#      buildstr="$buildstr $xym -" ;;
#    cfj )
#      buildstr="$buildstr $cfj -" ;;
#  esac

  eval tmptest='$'$part2; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

# 1-offs
  case "$part3" in
#    mgm )
#      buildstr="$buildstr $mgm -" ;;
#    app )
#      buildstr="$buildstr $app -" ;;
    web )
      buildstr="$buildstr Webserver -" ;;
  * )
# Fallthru
    eval tmptest='$'$part3; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

  esac

#  case "$part4" in
#    sb )
#      buildstr="$buildstr $sb -" ;;
#    de )
#      buildstr="$buildstr $de -" ;;
#    np )
#      buildstr="$buildstr $np -" ;;
#    cs )
#      buildstr="$buildstr $cs -" ;;  
#    ss )
#      buildstr="$buildstr $ss -" ;;  
#    pr )
#      buildstr="$buildstr $pr -" ;;
#    te )
#      buildstr="$buildstr $te -" ;;
#  esac

  eval tmptest='$'$part4; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

  buildstr="$buildstr $part5"
  echo "$buildstr"
exit 0;
}

function transonprem () {
# arg=chdbadmp99
#               1
#     01234567890
[ $debugg -gt 0 ] && echo ${arg:0:2}'<1 '${arg:2:2}'<2 '${arg:4:3}'<3 '${arg:7:1}'<4 '${arg:8:2}'<5 '
#ch<1 db<2 adm<3 p<4 01<5 

  part1=${arg:0:2}
  part2=${arg:2:2}
  part3=${arg:4:3}
  part4=${arg:7:1}
  part5=${arg:8:2}

#[ $debugg -gt 0 ] && echo "part1=$part1..gt=$gt" 
  case "$part1" in
    ch )
      buildstr="$arg = $ch -" ;;
    sa )
      buildstr="$arg = $sa -" ;;
  esac

#  case "$part2" in
#    db )
#      buildstr="$buildstr $db -" ;;
#    lx )
#      buildstr="$buildstr $lx -" ;;
#  esac

  eval tmptest='$'$part2; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

#  case "$part3" in
#    azs )
#      buildstr="$buildstr $azs -" ;;
#    dbg )
#      buildstr="$buildstr $dbg -" ;;
#    gms )
#      buildstr="$buildstr $gms -" ;;
#    web )
#      buildstr="$buildstr $web -" ;;
#  esac

  eval tmptest='$'$part3; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

#  case "$part4" in
#    s )
#     buildstr="$buildstr $s -" ;;
#    d )
#      buildstr="$buildstr $d -" ;;
#    t )
#      buildstr="$buildstr $t -" ;;
#    q )
#      buildstr="$buildstr $q -" ;;  
#    p )
#      buildstr="$buildstr $p -" ;;
#    h )
#      buildstr="$buildstr $h -" ;;
#  esac

  eval tmptest='$'$part4; [ "$tmptest" = "" ] ||buildstr="$buildstr $tmptest -"

  buildstr="$buildstr $part5"
  echo "$buildstr"
exit 0;
}


#############################
# MAIN
arg="$1"
# ${string:position:length}  ## 0-indexed!

prefix3=${arg:0:3}
prefix2=${arg:0:2}

case "$prefix3" in
  zgq ) 
    transazure ;;
  zgb ) 
    transazure ;;
  
  aw1 )
    transamazon ;;
esac

case "$prefix2" in
  ch )
    transonprem ;;
  sa )
    transonprem ;;
          
  * )
# Fallthru
     failexit 404 "Unknown server prefix - please add to code or correct input argument"
esac

exit;


# REF: https://tldp.org/LDP/abs/html/string-manipulation.html
# REF: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html

# REF: shared drive AHE Unix Onboarding docs "ServerList.txt" and ServerNamingConventions.txt

# Latest updates at top

2022.0119 (DONE) IDEA - refactored to use eval, generic version rev
# REF: https://unix.stackexchange.com/questions/23111/what-is-the-eval-command-in-bash
This saves A LOT on coding, and nearly no update-in-two-places unless 1-offs
v1.2

$ echo $sname
 ssdsotweb01
#          1
#01234567890
web="Web Server"

part=${sname:6:3}; echo $part
web

#eval testt=$web; if blank, NOP OR printit
eval testt='$'$part; [ "$testt" = "" ] ||echo $testt
Web Server

#=============

