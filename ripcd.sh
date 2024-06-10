#!/bin/bash
# Reads CDRs from SAF 24x

# NOTE - The DVD burner on p500 is much FASTER for audio ripping.

usecd="/dev/sr0"

#mount /mnt/cdtemp2a
#cd /mnt/cdtemp/audio
cd /bigvaiterazfs/dv/compr/audio/cdrips/

# if no parm, just rip generic - else mkdir albumname
if [ "$1" != "" ]; then 
  mkdir $1 && \
  cd $1
fi

echo 'o Ripping CD to ';pwd

# Scsi bprec
#cdda2wav -D$CDR_DEVICE -x "-t1+" -Owav -B

# CDRW
time cdda2wav -D$usecd --no-infofile -x "-t1+" -Owav -B \
  -n 128 -S 32 
#-paranoia

chown -R dave .
ls -alh
pwd

##$CDR_DEVICE 
# -n 64?
# add " -V -s speed" if nec

#cdparanoia -d /dev/cdrom2 --batch "1-"
#cdparanoia --batch "1-"

# Worx faster without forcereadspd
#cdparanoia -S 1 --batch "1-"

eject $usecd
#cdrom
#sr0
#cdrom
