#!/bin/bash

# REF: https://www.youtube.com/watch?v=vZR2wz6xhRU&t=187s

# NOTE - login on phone as admin to see notifications!

unset ftp_proxy
unset http_proxy
#https_proxy=https://10.108.187.118:3128


if [ "$1" = "" ] || [ "$1" = '.' ]; then
  arg1="General notification from $(hostname)@$(hostname -i)"
else
  arg1="General notification: $(hostname)@$(hostname -i) - $1"
fi

if [ "$2" = "" ] || [ "$2" = '.' ]; then
  arg2="$(date) - General notification from $(hostname)"
else
  arg2="$(date) - General notification: $2"
fi

# IP of gotify container
curl "http://gotify.local/message?token=YOURAPIKEYHERE" -F "title=$arg1" -F "message=$arg2" -F "priority=5"
# token from webui Applications
