#!/bin/bash

# Adapted from: https://www.systutorials.com/improving-sshscp-performance-by-choosing-ciphers/

# if not exist, create
[ -e $HOME/.ssh/id_rsa.pub ] || ssh-keygen -t rsa -q -N ''

# Passwordless run
ssh-copy-id $(whoami)@localhost

echo "$(date) - Running timing tests"
for i in 3des-cbc \
 aes128-cbc aes128-ctr aes128-gcm@openssh.com \
 aes192-cbc aes192-ctr \
 aes256-cbc aes256-ctr aes256-gcm@openssh.com \
 arcfour arcfour128 arcfour256  \
 blowfish-cbc \
 cast128-cbc  \
 chacha20-poly1305@openssh.com \
 rijndael-cbc@lysator.liu.se; 
do 
  dd if=/dev/zero bs=1000000 count=1000 2>/dev/null \
   |ssh -c $i localhost "(time -p cat) >/dev/null" 2>&1 \
   |grep real \
   |awk '{print "'$i': "1000 / $2" MB/s" }'
done |column -t

date

exit;

aes128-ctr:                     104.822  MB/s
aes128-gcm@openssh.com:         85.1789  MB/s
aes192-ctr:                     91.4077  MB/s
aes256-ctr:                     79.1766  MB/s
aes256-gcm@openssh.com:         71.8907  MB/s
chacha20-poly1305@openssh.com:  168.35   MB/s
