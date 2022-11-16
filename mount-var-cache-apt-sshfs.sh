#!/bin/bash
# REF: https://superuser.com/questions/32884/sshfs-mount-without-compression-or-encryption

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Proof of concept, mount /var/cache/apt to a networked location with more free space so can DL packages for Debian/derived upgrade
# Useful for raspberry pi SDCARD, other systems you should be able to add another disk (virtual) or use USB external disk

/bin/mv -v /var/cache/apt /var/cache/apt-old
mkdir -pv /var/cache/apt

#sshfs -o sshfs_debug -d -C -o Ciphers=chacha20-poly1305@openssh.com  user@imacdual-linux:/zredteraB/shrcompr-zrtB /mnt/imacdual -o nonempty
# xxx TODO EDITME
sshfs -C -o Ciphers=chacha20-poly1305@openssh.com \
  dave@10.9.13.4:/Volumes/sgtera2/var-cache-apt /var/cache/apt -o idmap=user
df -hT

ls -al /var/cache
[ $(df |grep -c /var/cache/apt) -gt 0 ] || failexit 101 "/var/cache/apt not mounted"

cd /var/cache/apt-old
pwd
echo "Enter to copy OLD /var/cache/apt files over, or ^C"
read

#time cp -apRv * /var/cache/apt
time rsync -av --remove-source-files --delete-after --max-delete=1 --prune-empty-dirs --progress \
  /var/cache/apt-old/* /var/cache/apt/

ls -alh /var/cache/apt
