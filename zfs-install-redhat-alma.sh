#!/bin/bash

# tested on alma linux 8.3 // centos / RHEL replacement

# Args/parameters to pass:
#
# upgrade = Unmount zfs datasets, export all zfs pools, unload zfs module, recompile zfs, reload module (does not re-import pools)
# fixit = just recompile zfs module for running kernel and load module

logfile=~/zfs-install-redhat-alma.log
mv -v $logfile $logfile-old
# blankit
> $logfile
chmod 750 $logfile

# xxx TODO EDITME
#zver="2.0.4"
zver="2.1.1"

firstrun=1
# if set to 1, will install prereq packages - set 0 to skip

# logecho.mrg 
# Echo something to current console AND log
# Can also handle piped input ( cmd |logecho )
# Warning: Has trouble echoing '*' even when quoted.
function logecho () {
  args=$@

  if [ -z "$args" ]; then
    args='placeholder'

    while [ 1 ]; do
      read -e -t2 args

      if [ -n "$args" ]; then
         echo "$args" |tee -a $logfile;
      else
        break;
      fi
    done

  else
    echo "$args" |tee -a $logfile;
  fi
} # END FUNC

if [ "$1" = "fixit" ]; then
  logecho "$(date) - Recompiling ZFS module for new/current kernel"

  cd /usr/local/src/zfs-$zver
  time rpm --reinstall zfs-dkms*.rpm && modprobe zfs

  dmesg |grep ZFS
  zpool version
  logecho "o $(date) + Finished run = $0 $1"

  exit;
fi

# failexit.mrg
function failexit () {
  logecho "$(date) - Something failed! Code: $1 $2" # code # (and optional description)
  exit $1
}

if [ "$1" = "upgrade" ]; then
  systemctl stop zed
  systemctl stop smb
# TODO also do nfs if you use that with zfs

  logecho "! $(date) - Unmounting all ZFS datasets and exporting pools..."
  zfs umount -a -f
  zpool export -a -f
  [ $(df -hT |grep -c zfs) -gt 0 ] && failexit 111 "! $(date) - ZFS pool/dataset found still mounted, lsof may come in handy"  
# handy REF if you need fuser: https://vander.host/knowledgebase/operating-systems/how-to-deal-with-fuser-command-not-found-on-centos/
# yum install -y psmisc

  logecho "o $(date) - Unloading ZFS modules..."
  modprobe -rv zfs zunicode zzstd zlua zcommon znvpair zavl icp spl
  if [ $(lsmod |grep -c zfs) -gt 0 ]; then
    logecho "NOTE if you get error here, ' lsof |grep zfs ' and kill the process holding it, then retry"
    failexit 302 "! ($date) - ZFS module(s) are still loaded!"
  fi
  
  yum remove -y zfs zfs-dkms* libnvpair* libuutil* libzfs* libzpool* python3-pyzfs zfs-debug* zfs-dracut zfs-test* \
    --setopt=clean_requirements_on_remove=false \
  || failexit 999 "! $(date) - Failed to uninstall ZFS RPMs"
# REF: https://access.redhat.com/solutions/5577491
# otherwise it removes ~128 packages and is a big PITA :b

  logecho "o $(date) - TODO NOTE upgrade was called, dont forget to restart services"
fi

if [ "$firstrun" -gt 0 ]; then
  logecho "o $(date) + Installing prereq pkgs..."
  yum install -y epel-release
#yum install -y https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm
#gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html

  yum install -y kernel-devel kernel-headers wget curl lsof
  yum groupinstall -y "Development Tools"

  dnf install -y gcc make autoconf automake libtool rpm-build kernel-rpm-macros dkms libtirpc-devel \
   libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel \
   elfutils-libelf-devel kernel-devel-$(uname -r) python3 python3-devel python3-setuptools python3-cffi libffi-devel
 
fi
 
cd /usr/local/src
logecho "o $(date) + Downloading ZFS source code"
wget --no-clobber https://github.com/openzfs/zfs/releases/download/zfs-$zver/zfs-$zver.tar.gz
tar xzf zfs-$zver.tar.gz 

cd zfs-$zver || failexit 404 "! $(date) - ZFS source code not found!"

logecho "o $(date) + Compiling ZFS"
# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html
time ./configure
time make -s -j4 rpm-utils rpm-dkms && \
  mv -v *.src.rpm ..
  
logecho "o $(date) + Installing ZFS RPMs" 
time yum localinstall -y *.$(uname -p).rpm *.noarch.rpm \
  || failexit 666 "! $(date) - Failed to install ZFS packages"

modprobe zfs
dmesg |grep ZFS

zpool version && \
 logecho "o $(date) + Now you should be able to issue ' zpool import '"

logecho "o $(date) + Finished run = $0 $1"

exit 0;

# Download and install zfs from source code, load module
# 2021 Dave Bechtel

REF:
https://zfsonlinux.topicbox.com/groups/zfs-discuss/T5e4d6ecb1044b00e
