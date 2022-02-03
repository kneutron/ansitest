#!/bin/bash5

# REF: https://www.reddit.com/r/bash/comments/sjfn3n/i_downloaded_my_reddit_comment_history_heres_the/
# Original author: whetu@reddit
# Kneutron: Mod for OSX 10.13 High Sierra, bash5, add forum download capability

# REQUIRES: curl, jq from ports

new_epoch="${1}"

# xxx TODO EDITME
user=zfsbest
forum=bash

use=forum

# Does not work with OSX default bash 3, use 'gdate' from ports
epoch=$(date +%s)
base_url="https://api.pushshift.io/reddit/comment/search"

if [ "$use" = "user" ]; then
  base_url+="/?author=${user}&sort=desc&sort_type=created_utc"
else
  base_url+="/?subreddit=${forum}&sort=desc&sort_type=created_utc"
fi

# TODO EDITME
base_dir=$HOME/Downloads/reddit/$use
mkdir -pv $base_dir $base_dir/$user $base_dir/$forum

req_count=0

# Initial download
if [[ ! -f "${base_dir}/${user}.json.latest" ]]; then
  curl -s "${base_url}" > "${base_dir}/${user}.json.latest"
  new_epoch=$(jq -r 'last(.[] | .[].created_utc)' "${base_dir}/${user}.json.latest")
  req_count=1
fi

while (( epoch != new_epoch )); do
  if (( req_count == 45 )); then
    printf -- '%s\n' "Snoozing for a bit to keep the remote server happy..."
    sleep 60
    req_count=0
  fi
  epoch="${new_epoch}"
  if [[ ! -f "${base_dir}/${user}.json.${epoch}" ]]; then
    printf -- '%s\n' "Downloading into ${base_dir}/${user}.json.${epoch} ($(date -d @"${epoch}"))"
    curl -s "${base_url}&before=${epoch}" > "${base_dir}/${user}.json.${epoch}"
    (( req_count++ ))
  else
    printf -- '%s\n' "Exists: ${base_dir}/${user}.json.${epoch}"
  fi
  new_epoch=$(jq -r 'last(.[] | .[].created_utc)' "${base_dir}/${user}.json.${epoch}")
  if (( "${#new_epoch}" == 0 )); then
    printf -- '%s\n' "Error getting new epoch value" >&2
    exit 1
  fi
done

date
