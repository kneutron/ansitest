#!/bin/bash

# 2026.Apr kneutron

# REF: https://linuxiac.com/upgrade-rocky-linux-8-to-rocky-linux-9/

REPO_URL="https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/r"
RELEASE_PKG="rocky-release-9.7-1.4.el9.noarch.rpm" # rocky-release-9.3-1.2.el9.noarch.rpm"
REPOS_PKG="rocky-repos-9.7-1.4.el9.noarch.rpm" # rocky-repos-9.3-1.2.el9.noarch.rpm"
GPG_KEYS_PKG="rocky-gpg-keys-9.7-1.4.el9.noarch.rpm" # rocky-gpg-keys-9.3-1.2.el9.noarch.rpm"

[ -e /usr/share/redhat-logos ] && /bin/rm -rfv /usr/share/redhat-logos

result=$(systemctl status auditd |grep -c dead)
if [ $result -ne 1 ]; then
  echo "Disabling auditd... reboot and rerun $0 or the upgrade will hang"
  systemctl disable auditd
  systemctl status auditd  --no-pager
  exit 1;
fi

dnf install $REPO_URL/$RELEASE_PKG $REPO_URL/$REPOS_PKG $REPO_URL/$GPG_KEYS_PKG || exit $?

dnf remove iptables-ebtables

time dnf -y --releasever=9 --allowerasing --setopt=deltarpm=false distro-sync || exit $?

rpm --rebuilddb
date

echo "OK to reboot"
