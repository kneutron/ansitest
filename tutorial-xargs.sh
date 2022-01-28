#!/bin/bash

exit;

# REF: http://www.oilshell.org/blog/2021/08/xargs.html

cd /Volumes/zsgtera4/shrcompr-zsgt2B 
ls *tar* |gxargs -n 1 -P 3 countdown 30

#(17) tar files, run 3 in parallel

while running, can watch -n 10 in split screen session:

$ ps -ef|grep countd
  501 38095 68669   0  1:02PM ttys014    0:00.00 gxargs -n 1 -P 3 countdown 30
  501 38096 38095   0  1:02PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 Mac-startup-key-combinations.pdf
  501 38097 38095   0  1:02PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 Star_Trek-Picard_Free_Series_Premiere_Episode_CBS_All_Access-1PPm5l3o2zw.mkv
  501 38098 38095   0  1:02PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 flist--kickstart-rhel79-dvd-davefiles.txt
  501 38106 37219   0  1:02PM ttys015    0:00.00 grep countd

(after count=0 , next )
$ ps -ef|grep countd
  501 38095 68669   0  1:02PM ttys014    0:00.01 gxargs -n 1 -P 3 countdown 30
  501 38203 38095   0  1:03PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 iscsi-server-config.tar
  501 38204 38095   0  1:03PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 iscsi-vm-configs.tar
  501 38206 38095   0  1:03PM ttys014    0:00.01 /bin/bash5 /Users/dave/bin/countdown 30 kickstart-rhel79-dvd-davefiles.tgz

# Believe it or not, I use this to randomize music and videos :)
find ... |shuf |xargs mplayer # pass randomized list to mplayer as args

/Volumes/zsgtera4/shrcompr-zsgt2B $ ls *tar* |shuf |xargs echo
kickstart-rhel79-dvd-davefiles.tgz rootbin-fryserver.tar.gz
osx-restart-sshd.sh Star_Trek-Picard_Free_Series_Premiere_Episode_CBS_All_Access-1PPm5l3o2zw.mkv
zfs-2.0.7.tar.gz flist--kickstart-rhel79-dvd-davefiles.txt zfs-2.1.1.tar.gz
ventoy-1.0.15-linux.tar.gz iscsi-server-config.tar ventoy-1.0.61-linux.tar.gz syncthing-linux-amd64-v1.14.0.tar.gz
zfs-0.8.6.tar.gz Mac-startup-key-combinations.pdf iscsi-vm-configs.tar kvpm-0.9.10.tar.gz
virtbox-vm--cubietruck-temp-replacement-squid-pihole.tar.lzop zfs-2.1.2.tar.gz

Run again, different order:
$ ls *tar* |shuf |xargs echo
ventoy-1.0.15-linux.tar.gz zfs-2.0.7.tar.gz iscsi-vm-configs.tar zfs-2.1.2.tar.gz Mac-startup-key-combinations.pdf
kickstart-rhel79-dvd-davefiles.tgz virtbox-vm--cubietruck-temp-replacement-squid-pihole.tar.lzop
kvpm-0.9.10.tar.gz Star_Trek-Picard_Free_Series_Premiere_Episode_CBS_All_Access-1PPm5l3o2zw.mkv
ventoy-1.0.61-linux.tar.gz rootbin-fryserver.tar.gz flist--kickstart-rhel79-dvd-davefiles.txt zfs-2.1.1.tar.gz 
zfs-0.8.6.tar.gz osx-restart-sshd.sh iscsi-server-config.tar syncthing-linux-amd64-v1.14.0.tar.gz

$ echo "alice bob dave fred" |xargs -n 2 echo 
alice bob
dave fred

$ echo "alice bob dave fred" |xargs -n 2 echo hi
hi alice bob
hi dave fred

NOTE xargs can basically "paste -" for everything in 1 line

# REF: https://www.tecmint.com/xargs-command-examples/

# for all *.sh files, wordcount lines in parallel=2 (faster)
$ ls *.sh |xargs -n 1 -P 2 wc -l

# fan a file out - cp to multiple dirs
echo target1 target2 |xargs -n 1 cp -v /path/sourcefile # cp sourcefile to both targets
# could also do this with scp!

You can enable verbosity using the -t flag, which tells xargs to print the
command line on the standard error output before executing it.

Running more than 1 command with xargs - REF: https://phoenixnap.com/kb/xargs-command
# [command-providing-input] | xargs -I % sh -c '[command-1] %; [command-2] %'

$ cat infile.txt |xargs -I % sh -c 'echo %; mkdir -pv %' # uses "%" as arg substitute
infile.txt:
folderone foldertwo folderthree


# REF: https://linuxhint.com/print-columns-awk/
# limit number of total fields printed in awk (actual input = 96, only print 24)
$ (echo sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) |awk '{for(i=1;i<=24;i++) printf $i" "; print ""}'
sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy

# cut can also do this (print a range of fields/limit)
$ (echo sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) |cut -d' ' -f1-24
sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
