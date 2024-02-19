#!/bin/bash
# Backup critical files (hopefully)

# Highly recommended to run this before doing ANY system updates/upgrades
# NOTE - BKPCRIT DESTINATION SHOULD NOT BE ON THE SAME DISK AS ROOT!!
# DEPENDS: lzop

#fixresolvconf

# xxx TODO EDITME
primaryuser=dave

source /root/bin/boojum/BKPDEST.mrg     # now provides mount test
drive=$bkpdest/notshrcompr

source /etc/os-release

# xxx TODO EDITME - set 1 if dest is ZFS compressed (lz4,zstd)
comprdest=0
if [ "$comprdest" = "1" ]; then
  taropts="-cpf "; tarsfx="tar"
else
#  taropts="--use-compress-program lzop -cpf "
  taropts="--lzop -cpf "; tarsfx="tar.lzop"
fi

rootpartn=$(df / |tail -n 1 |awk '{print $1}') # /dev/sde1
rootpedit=$(echo ${rootpartn##*/}) # strip off beginning, and last slash: sde1
#dest="$drive/notshrcompr/bkpcrit-$myhn--fryserver--linux-xubuntu1404LTS-64--$rootpedit" #sdX1"
dest="$drive/bkpcrit-$myhn--$rootpedit" #sdX1 
# xxx TODO EDITME
echo $dest # = PK

mkdir -pv $dest
chmod 750 $dest # drwxr-x---

tdate=$(date +%Y%m%d) # 19990909

# Copy this bkp script to bkpdest
cp -v $0 $dest
cp -v ~/localinfo.dat $dest
[ -e /etc/inittab ] && cp -v /etc/inittab $dest
cp -v /etc/fstab $dest
cp -v /tmp/smartctl.txt $dest
cp -v /tmp/fdisk-l.txt $dest/fdisk-l-$tdate.txt

echo 'o Clearing old files'
 # !! find bkp-gz, bkp-bz2 and flist files more than ~2 weeks old and delete
 cd $dest && \
   find $dest/* \( -name "*.txt" -o -name "flist*" \) -type f -mtime +15 -exec /bin/rm -v {} \;
#   find $dest/* \( -name "*.txt" -o -name "bkp*bz2" -o -name "flist*" \) -type f -mtime +20 -exec /bin/rm -v {} \;
   

# document system state
mount |egrep -v 'tmpfs|cgroup' |column -t >> $dest/fdisk-l-$tdate.txt # xxx 2017.0218
df -hT > $dest/df-h.txt # added 2016.april
df -T -x{tmpfs,usbfs} > $dest/df-$tdate.txt	# nice to have non-h df as well

# removed 2016.0319, not using lvm
#vgdisplay -v > $dest/vgdisplay-v-$tdate.txt

# xxx TODO editme
distro="debian"
testd=$(grep ID_LIKE /etc/os-release |awk -F\" '{print $2}') # rhel fedora
testd=${testd// /-}    # bash inline sed, replace space with dash
[ "$testd" = "" ] || distro="$testd"

tar $taropts $dest/bkp-boot--$distro.$tarsfx /boot

tar $taropts $dest/bkp-ETC--$distro.$tarsfx /etc

tar $taropts $dest/bkp-NXETC--$distro.$tarsfx /usr/NX/etc
tar $taropts $dest/bkp-NXSHARE--$distro.$tarsfx /usr/NX/share
tar $taropts $dest/bkp-NXVAR--$distro.$tarsfx /usr/NX/var

# this can probably be skipped with udev auto-dev population, but may come in handy on older platforms
tar $taropts $dest/bkp-DEV--$distro.$tarsfx /dev

tar $taropts $dest/bkp-rootshomedirectory--$distro.$tarsfx /root

tar $taropts $dest/bkp-usr-local-bin--$distro.$tarsfx /usr/local/bin /usr/local/sbin
#tar $taropts $dest/bkp-usr-local-sbin-$distro.$tarsfx /usr/local/sbin

tar $taropts $dest/bkp-var-dpkg-status.$tarsfx /var/lib/dpkg
tar $taropts $dest/bkp-var-dpkg-backups.$tarsfx /var/backups
tar $taropts $dest/bkp-var-cache-apt-backups.$tarsfx /var/cache/apt

# proxmox
tar $taropts $dest/bkp-var-lib-vz.$tarsfx /var/lib/vz
tar $taropts $dest/bkp-var-lib-pve-cluster.$tarsfx /var/lib/pve-cluster


# rhel-related distros
tmp=/var/cache/yum;  [ -e "$tmp" ] && tar $taropts $dest/bkp-var-cache-yum--$distro.$tarsfx $tmp
tmp=/var/lib/rpm;    [ -e "$tmp" ] && tar $taropts $dest/bkp-var-lib-rpm--$distro.$tarsfx $tmp
tmp=/var/lib/yum;    [ -e "$tmp" ] && tar $taropts $dest/bkp-var-lib-yum--$distro.$tarsfx $tmp
tmp=/var/log/secure; [ -e "$tmp" ] && tar $taropts $dest/bkp-var-log-secure--$distro.$tarsfx $tmp /var/log/yum.log


tar $taropts $dest/bkp-$primaryuser-src.$tarsfx /home/$primaryuser/src
tar $taropts $dest/bkp-$primaryuser-bin.$tarsfx /home/$primaryuser/bin


# Dotfiles
#cd /root
#tar cpvzf $dest/bkp-root-dotfiles--restore-locally$tarsfx .[^.]*

# thunderbird is just email, goes in bkphome
# NOTE - to see size of hidden dirs: du -hs .[^.]* # REF: http://superuser.com/questions/342448/du-command-does-not-parse-hidden-directories
cd /home/$primaryuser

#  --exclude='.thunderbird' \
tar \
  --exclude='.kde/share/thumbnails' \
  --exclude='.kde/share/cache' \
  --exclude=".pan/*" \
  --exclude='.gqview/thumbnails' \
  --exclude='.thumbnails' \
  --exclude='.opera/cache4' \
  --exclude='.opera/thumbnails' \
  --exclude=".cache/*" \
  --exclude=".mozilla/firefox/*" \
  --exclude=".moonchild productions/pale moon/*" \
  --exclude='..' \
  $taropts $dest/bkp-$primaryuser-dotfiles--restore-locally.$tarsfx .[^.]*

#  --exclude=".mozilla/firefox/*.default/Cache*" \

#sync

ls $dest -alh
df -hT $drive
echo $dest
echo "$(date) - $0 done"

exit;


2021.april mod for redhat/rpm-based distros (not tested on SuSE) and try to auto-determine distro type

Copyright (C) 1999, 2000 and beyond David J Bechtel

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

<a href="http://www.gnu.org/copyleft/gpl.html"> The GNU Copyleft </a><br>
