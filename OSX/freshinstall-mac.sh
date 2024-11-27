#!/bin/bash
# /opt/local/bin/bash

port-install.sh -N bash bwm-ng sysstat joe
#port-install.sh -N mc +sftp

port-install.sh -N grsync xaos md5sha1sum openjdk11 mutt mediainfo geeqie \
  putty shellcheck gawk jc jq sxiv unison lf inetutils nomacs kitty \
 tmux byobu html2text flock gptfdisk gsed pv watch parallel findutils \
 nmap imagemagick buffer lame veracrypt git rclone mediainfo
 
# TODO ntp
# ristretto build fail 2023.0321
# atom no longer avail
