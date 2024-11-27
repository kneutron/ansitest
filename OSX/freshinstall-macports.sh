#!/bin/bash

# no usrlocalbin - that 4 brew
PATH=/var/root/bin:/var/root/bin/boojum:/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin:/opt/local/bin:

# avoid conflicts/errs with brewstuff
mv -v /usr/local/include /usr/local/notinclude

# no lsof; hfstar build failed
port -N install autossh bash bwm-ng bzip2 cmatrix coreutils curl detox ffmpeg flock gnutar gptfdisk grsync \
 gsmartcontrol gstreamer1 htop iftop imagemagick iperf3 joe lame lftp lz4 lzma lzo2 lzop nmap p7zip \
 parallel pidof pigz pstree pv smartmontools ssh-copy-id sshfs util-linux watch youtube-dl yt-dlp \
 wget zstd

#port uninstall mc
#port clean mc
#port install mc +sftp

[ -e /usr/local/notinclude ] && mv -v /usr/local/notinclude /usr/local/include

date

exit;
