#!/bin/bash

# 2021 Dave Bechtel
# Generate a (hopefully) unique AWS S3 bucket name with arbitrary padding length up to limit
# REQUIRES: sha1sum, sha256sum, tr, cut

echo "$0 - arg1=prefix + [optional] arg2 = # of pad chars (limit 63)"
arg="$1"
prefix="${arg,,}" # LC 

# int
declare -i pad=30 # chars, limit 63
[ "$2" = "" ] || pad=$2
[ $pad -gt 63 ] && pad=63

# must consist of lowercase letters, numbers, periods, and hyphens

out1=$(echo "$(date)$prefix" |sha1sum) 
sleep 1 
#out2=$(echo "$prefix$(date)" |sha1sum)
out2=$(echo "$out1$((1 + $RANDOM % 99))$(date)" |sha256sum)
# include random number from 1-99 to try and prevent collisions

result=$(echo "$prefix-rbn-$out2" |tr ' ' '.' |cut -c 1-$pad)

echo '         1         2         3         4         5         6  6'
echo '123456789012345678901234567890123456789012345678901234567890123'
echo "$result"

exit;


# e.g.
$ s3-bucket-unique-name.sh testberferd1 40
s3-bucket-unique-name.sh - arg1=prefix + [optional] arg2 = # of pad chars (limit 63)
         1         2         3         4         5         6  6
123456789012345678901234567890123456789012345678901234567890123
testberferd1-rbn-f9d0ee0c77beb5a769fdd1b

^ Running the same command twice with same parms should always generate a different result
