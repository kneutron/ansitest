#!/bin/bash

# Verbosely list the contents of various storage defined in the Proxmox GUI
# 2024.May kneutron
# Could be handy to grep the output for e.g. vm-112 or an ISO name to see which storage has it
# Also handy to find backups of a VM on different storage

# running from cron, we need this
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

logf=proxmox-storage-report.log
cd /root 
/bin/mv -v $logf $logf-prev

(for ds in $(pvesm status |grep -v Total |awk '{print $1}'); do 
	echo "o Storage $ds:"
	pvesm list "$ds"
	echo '====='
done) 2>/dev/null |tee $logf

ls -lh $logf*

exit;

Example output:
=======

o dir1:
Volid                                                                Format  Type              Size VMID
dir1:105/vm-105-disk-1.raw                                           raw     rootdir     2147483648 105
dir1:backup/vzdump-lxc-102-2024_02_15-03_00_00.tar.zst               tar.zst backup       852300917 102
dir1:backup/vzdump-lxc-105-2024_05_05-03_02_03.tar.zst               tar.zst backup       229723580 105
dir1:backup/vzdump-lxc-105-2024_05_06-03_02_11.tar.zst               tar.zst backup       229723096 105
dir1:backup/vzdump-lxc-105-2024_05_07-03_02_00.tar.zst               tar.zst backup       229723252 105
dir1:backup/vzdump-lxc-105-2024_05_08-03_02_10.tar.zst               tar.zst backup       229727278 105
dir1:backup/vzdump-lxc-110-2024_03_30-00_15_26.tar.zst               tar.zst backup     83294043758 110
dir1:backup/vzdump-lxc-110-2024_04_06-00_15_34.tar.zst               tar.zst backup     83294069095 110
dir1:backup/vzdump-lxc-113-2024_03_12-14_43_06.tar.zst               tar.zst backup      1423115359 113
dir1:backup/vzdump-lxc-113-2024_03_30-00_53_35.tar.zst               tar.zst backup      1423116767 113
dir1:backup/vzdump-lxc-113-2024_04_06-01_08_27.tar.zst               tar.zst backup      1423117625 113
dir1:backup/vzdump-lxc-114-2024_03_12-14_44_57.tar.zst               tar.zst backup      1483148389 114
dir1:backup/vzdump-lxc-114-2024_03_30-00_54_40.tar.zst               tar.zst backup      1481744306 114
dir1:backup/vzdump-lxc-114-2024_04_06-01_09_31.tar.zst               tar.zst backup      1481744776 114
dir1:backup/vzdump-lxc-115-2024_03_24-19_59_03.tar.zst               tar.zst backup       144860326 115
dir1:backup/vzdump-lxc-118-2024_03_30-00_55_43.tar.zst               tar.zst backup     41888944892 118
dir1:backup/vzdump-lxc-118-2024_04_06-01_10_31.tar.zst               tar.zst backup     41918533007 118
dir1:backup/vzdump-lxc-118-2024_04_20-10_38_53.tar.zst               tar.zst backup       568941879 118
dir1:backup/vzdump-qemu-100-2024_05_05-01_00_06.vma.zst              vma.zst backup      7835837436 100
dir1:backup/vzdump-qemu-101-2024_05_05-01_02_23.vma.zst              vma.zst backup          954663 101
dir1:backup/vzdump-qemu-103-2024_02_22-21_09_47.vma.zst              vma.zst backup     67731821727 103
dir1:backup/vzdump-qemu-104-2024_05_05-03_00_06.vma.zst              vma.zst backup      2767913034 104
dir1:backup/vzdump-qemu-104-2024_05_06-03_00_15.vma.zst              vma.zst backup      2543285853 104
dir1:backup/vzdump-qemu-104-2024_05_07-03_00_03.vma.zst              vma.zst backup      2523604716 104
dir1:backup/vzdump-qemu-104-2024_05_08-03_00_16.vma.zst              vma.zst backup      2837215166 104
dir1:backup/vzdump-qemu-106-2024_05_05-01_02_49.vma.zst              vma.zst backup             620 106
dir1:backup/vzdump-qemu-107-2024_03_02-01_01_07.vma.zst              vma.zst backup     28297664504 107
dir1:backup/vzdump-qemu-107-2024_04_06-16_49_13.vma.zst              vma.zst backup     26717703404 107
dir1:backup/vzdump-qemu-108-2024_02_28-17_27_03.vma.zst              vma.zst backup      5549487004 108
dir1:backup/vzdump-qemu-108-2024_05_05-03_02_48.vma.zst              vma.zst backup      8481354814 108
dir1:backup/vzdump-qemu-108-2024_05_06-03_02_58.vma.zst              vma.zst backup      8488706790 108
dir1:backup/vzdump-qemu-108-2024_05_07-03_02_48.vma.zst              vma.zst backup      8481379614 108
dir1:backup/vzdump-qemu-108-2024_05_08-03_03_00.vma.zst              vma.zst backup      8479349801 108
dir1:backup/vzdump-qemu-109-2024_05_05-03_04_23.vma.zst              vma.zst backup      1913285620 109
dir1:backup/vzdump-qemu-109-2024_05_06-03_04_36.vma.zst              vma.zst backup      1892669891 109
dir1:backup/vzdump-qemu-109-2024_05_07-03_04_27.vma.zst              vma.zst backup      1871088686 109
dir1:backup/vzdump-qemu-109-2024_05_08-03_04_37.vma.zst              vma.zst backup      1870107272 109
dir1:backup/vzdump-qemu-111-2024_05_05-03_06_21.vma.zst              vma.zst backup      1265609986 111
dir1:backup/vzdump-qemu-111-2024_05_06-03_06_42.vma.zst              vma.zst backup      1255926232 111
dir1:backup/vzdump-qemu-111-2024_05_07-03_06_26.vma.zst              vma.zst backup      1258063225 111
dir1:backup/vzdump-qemu-111-2024_05_08-03_06_37.vma.zst              vma.zst backup      1266230955 111
dir1:backup/vzdump-qemu-112-2024_02_25-11_18_53.vma.zst              vma.zst backup     19993936753 112
dir1:backup/vzdump-qemu-115-2024_04_14-17_41_29.vma.zst              vma.zst backup      5760632721 115
dir1:backup/vzdump-qemu-115-2024_04_16-15_07_13.vma.zst              vma.zst backup      3526050735 115
dir1:backup/vzdump-qemu-117-2024_02_22-10_55_20.vma.zst              vma.zst backup     67889353524 117
dir1:backup/vzdump-qemu-119-2024_05_05-01_02_49.vma.zst              vma.zst backup      9653379368 119
dir1:backup/vzdump-qemu-120-2024_05_05-01_06_08.vma.zst              vma.zst backup      6207397992 120
dir1:backup/vzdump-qemu-121-2024_05_05-01_09_49.vma.zst              vma.zst backup    491076225929 121
dir1:iso/4MLinux-36.0-64bit.iso                                      iso     iso          975175680
dir1:iso/AiO-SRT_2018-01-02.iso                                      iso     iso          695205888
dir1:iso/AlmaLinux-8.7-x86_64-boot.iso                               iso     iso          856686592
dir1:iso/AlmaLinux-8.7-x86_64-minimal.iso                            iso     iso         1777336320
dir1:iso/AlmaLinux-8.8-x86_64-boot.iso                               iso     iso          902823936
dir1:iso/AlmaLinux-9.2-x86_64-boot.iso                               iso     iso          904921088
dir1:iso/AlmaLinux-9.3-x86_64-boot.iso                               iso     iso          942669824
dir1:iso/AlmaLinux-9.3-x86_64-dvd.iso                                iso     iso        10916724736
dir1:iso/AlmaLinux-9.3-x86_64-minimal.iso                            iso     iso         1860173824
dir1:iso/antiX-21-net_x64-net.iso                                    iso     iso          184549376
dir1:iso/antiX-21_x64-core.iso                                       iso     iso          458227712
dir1:iso/antiX-22_x64-full.iso                                       iso     iso         1498415104
dir1:iso/antiX-23-net_x64-net.iso                                    iso     iso          252706816
dir1:iso/antiX-23.1-net_x64-net.iso                                  iso     iso          253755392
dir1:iso/APFS_EFI_Boot_Image.iso                                     iso     iso            1048576
dir1:iso/archlinux-alez-2020.07.28.04.34.53-x86_64.iso               iso     iso          729808896
dir1:iso/bl-Helium_i386_cdsized+build2.iso                           iso     iso          704643072
dir1:iso/boot-repair-disk-64bit.iso                                  iso     iso          922746880
dir1:iso/CentOS-7-x86_64-Minimal-2003.iso                            iso     iso         1085276160
dir1:iso/CentOS-7-x86_64-NetInstall-2003.iso                         iso     iso          595591168
dir1:iso/CentOS-8.1.1911-x86_64-boot.iso                             iso     iso          625999872
dir1:iso/CentOS-Stream-x86_64-dvd1.iso                               iso     iso         8572108800
dir1:iso/clonezilla-live-3.1.2-22-amd64.iso                          iso     iso          442499072
dir1:iso/CorePlus-current.iso                                        iso     iso          164626432
dir1:iso/dCorePlus-stretch64.iso                                     iso     iso          213909504
dir1:iso/debian-11.5.0-amd64-DVD-1.iso                               iso     iso         3897638912
dir1:iso/debian-11.7.0-amd64-netinst.iso                             iso     iso          407896064
dir1:iso/debian-12.0.0-amd64-netinst.iso                             iso     iso          773849088
dir1:iso/debian-12.5.0-amd64-netinst.iso                             iso     iso          659554304
dir1:iso/debian-live-12.0.0-amd64-xfce.iso                           iso     iso         3305668608
dir1:iso/debian-testing-bookworm-DI-rc2-amd64-netinst.iso            iso     iso          797966336
dir1:iso/deepin-desktop-community-1010-amd64.iso                     iso     iso         2983620608
dir1:iso/devuan_chimaera_4.0.0_amd64_netinstall.iso                  iso     iso          390070272
dir1:iso/devuan_chimaera_4.0.0_i386_netinstall.iso                   iso     iso          424673280
dir1:iso/devuan_daedalus_5.0.0_amd64_minimal-live.iso                iso     iso          836763648
dir1:iso/devuan_daedalus_5.0.0_amd64_netinstall.iso                  iso     iso          499908608
dir1:iso/devuan_daedalus_5.0.1_i386_netinstall.iso                   iso     iso          506265600
dir1:iso/devuan_daedalus_5.0.preview-20230501_i386_netinstall.iso    iso     iso          484442112
dir1:iso/devuan_daedalus_5.0.preview-20230601_amd64_netinstall.iso   iso     iso          469762048
dir1:iso/Dr.Parted-Live-23.05-amd64.iso                              iso     iso          788529152
dir1:iso/Dr.Parted-Live24.03.1-amd64.iso                             iso     iso          725614592
dir1:iso/drivers-virtio-win-0.1.171.iso                              iso     iso          371732480
dir1:iso/elive_3.8.30_beta_hybrid_amd64.iso                          iso     iso         3925868544
dir1:iso/elive_3.8.30_beta_hybrid_i386.iso                           iso     iso         3097722880
dir1:iso/esxi-7-VMware-VMvisor-Installer-7.0U3g-20328353.x86_64.iso  iso     iso          401446912
dir1:iso/extix-21.1-64bit-deepin-20.1-live-2570mb-210103.iso         iso     iso         2760130560
dir1:iso/finnix-123.iso                                              iso     iso          432013312
dir1:iso/fossapup64-9.5.iso                                          iso     iso          428867584
dir1:iso/FreeBSD-13.1-RELEASE-amd64-bootonly.iso                     iso     iso          383877120
dir1:iso/freedos-FD13LIVE.iso                                        iso     iso          419573760
dir1:iso/FreeNAS-11.2-U7.iso                                         iso     iso          602378240
dir1:iso/FuryBSD-12.1-KDE-2020090701.iso                             iso     iso          644562691
dir1:iso/GeckoLinux-SUSE-based--ROLLING_Mate.x86_64-999.220115.0.iso iso     iso         1833631744
dir1:iso/GeckoLinux_STATIC_XFCE.x86_64-154.220822.0.iso              iso     iso         1721565184
dir1:iso/gparted-live-1.4.0-6-amd64.iso                              iso     iso          507510784
dir1:iso/guix-system-install-1.0.0.x86_64-linux.iso                  iso     iso         1375719424
dir1:iso/haiku-r1beta4-x86_64-anyboot--beOS.iso                      iso     iso         1477246976
dir1:iso/HBCD_PE_x64.iso                                             iso     iso         3099203584
dir1:iso/hello-0.5.0_0E223-FreeBSD-12.2-amd64.iso                    iso     iso         1364428800
dir1:iso/hrmpf-x86_64-6.1.3_1-20230105.iso                           iso     iso         1801322496
dir1:iso/ipfire-2.29-core184-x86_64.iso                              iso     iso          433061888
dir1:iso/ipxe-network-boot.iso                                       iso     iso            4194304
dir1:iso/john-ringo-hells-faire-posleen-free-cd--2003.iso            iso     iso          282300416
dir1:iso/kanotix32-silverfire-nightly-LXDE.iso                       iso     iso         1452277760
dir1:iso/kanotix64-silverfire-nightly-KDE.iso                        iso     iso         2455764992
dir1:iso/kanotix64-silverfire-nightly-LXDE.iso                       iso     iso         2211446784
dir1:iso/kanotix64-slowfire-nightly-LXDE.iso                         iso     iso         2459959296
dir1:iso/KNOPPIX_V8.6-2019-08-08-EN.iso                              iso     iso         4644143104
dir1:iso/KNOPPIX_V8.6.1-2019-10-14-EN.iso                            iso     iso         4646207488
dir1:iso/KNOPPIX_V9.1DVD-2021-01-25-EN.iso                           iso     iso         4694753280
dir1:iso/KS-RHEL79-NUKE-COSATDEV-SAT6.iso                            iso     iso         4699662336
dir1:iso/kumander-linux-1.0-live-amd64-fast-xfce-desktop-debian.iso  iso     iso         4719181824
dir1:iso/latest-nixos-minimal-x86_64-linux.iso                       iso     iso          865075200
dir1:iso/latest-nixos-plasma5-x86_64-linux.iso                       iso     iso         1782890496
dir1:iso/linux-lite-5.0-64bit--ubu2004-xfce--has-zfs-installer.iso   iso     iso         1405091840
dir1:iso/linuxmint-20-xfce-64bit.iso                                 iso     iso         1949515776
dir1:iso/linuxmint-20.3-cinnamon-64bit.iso                           iso     iso         2251653120
dir1:iso/linuxmint-21.1-mate-64bit.iso                               iso     iso         2742749184
dir1:iso/linuxmint-21.2-cinnamon-64bit.iso                           iso     iso         3026413568
dir1:iso/LiveRecoverySystem-201908-13.iso                            iso     iso         1204813824
dir1:iso/lmde-4-cinnamon-64bit.iso                                   iso     iso         2028060672
dir1:iso/lmde-5-cinnamon-64bit.iso                                   iso     iso         2061582336
dir1:iso/lmde-6-cinnamon-64bit.iso                                   iso     iso         2690580480
dir1:iso/macos-monterey-install.iso                                  iso     iso        17179869184
dir1:iso/macOS_Monterey_by_Techrechard.com.iso                       iso     iso        16148070400
dir1:iso/memtest86+-5.01.iso                                         iso     iso            1839104
dir1:iso/MidnightBSD-2.2.4--amd64-disc1.iso                          iso     iso          812402688
dir1:iso/mt86plus64.grub.iso                                         iso     iso           19953664
dir1:iso/mt86plus64.iso                                              iso     iso            6193152
dir1:iso/mt86plus_6.10_64.iso                                        iso     iso            6193152
dir1:iso/MX-21.1_x64.iso                                             iso     iso         1920991232
dir1:iso/MX-21.2.1_Workbench_x64.iso                                 iso     iso         1620049920
dir1:iso/MX-21.3_x64.iso                                             iso     iso         1957691392
dir1:iso/MX-23.1_x64.iso                                             iso     iso         2243952640
dir1:iso/MX-23_x64.iso                                               iso     iso         2189426688
dir1:iso/netboot.xyz.iso                                             iso     iso            2390016
dir1:iso/nitrux-nx-desktop-plasma-99bbba9e-amd64.iso                 iso     iso         3405559808
dir1:iso/OpenMandrivaLx.4.3-plasma.x86_64.iso                        iso     iso         2527805440
dir1:iso/openSUSE-Leap-15.5-NET-x86_64-Build491.1-Media.iso          iso     iso          212860928
dir1:iso/openSUSE-Tumbleweed-DVD-x86_64-Snapshot20240321-Media.iso   iso     iso         4466933760
dir1:iso/openSUSE-Tumbleweed-NET-x86_64-Snapshot20221004-Media.iso   iso     iso          228589568
dir1:iso/openSUSE-Tumbleweed-NET-x86_64-Snapshot20240223-Media.iso   iso     iso          289406976
dir1:iso/OracleLinux-R9-U3-x86_64-dvd.iso                            iso     iso        11034165248
dir1:iso/OSX-ElCap-Installer.iso                                     iso     iso         8294236160
dir1:iso/osx-highsierra-1013-install-CORRECTED-CERT.iso              iso     iso         5767168000
dir1:iso/osx-mojave-1014_6-install.iso                               iso     iso         8283750400
dir1:iso/pclinuxos64-kde-darkstar-2022.04.30.iso                     iso     iso         1870659584
dir1:iso/PeppermintOS-devuan_64_xfce.iso                             iso     iso         1495203840
dir1:iso/plop-boot-usb-from-iso.iso                                  iso     iso             557056
dir1:iso/plpbt.iso                                                   iso     iso             557056
dir1:iso/plpbtin.iso                                                 iso     iso             557056
dir1:iso/proxmox-ve_8.0-2.iso                                        iso     iso         1194483712
dir1:iso/proxmox-ve_8.2-1-auto-from-iso.iso                          iso     iso         1396899840
dir1:iso/proxmox-ve_8.2-1.iso                                        iso     iso         1395881984
dir1:iso/pxe--netboot.xyz.iso                                        iso     iso            2428928
dir1:iso/refind-cd-0.13.2.iso                                        iso     iso           14772224
dir1:iso/refind-cd-0.14.0.2.iso                                      iso     iso           14983168
dir1:iso/refracta_11_xfce_amd64-20211114_0127.iso                    iso     iso         1270087680
dir1:iso/rescatux-0.73.iso                                           iso     iso          724566016
dir1:iso/rescatux-0.74.iso                                           iso     iso          747634688
dir1:iso/rescuezilla-2.2-64bit.hirsute.iso                           iso     iso          947429376
dir1:iso/rhel-8.6-x86_64-boot.iso                                    iso     iso          887095296
dir1:iso/rhel-baseos-9.0-x86_64-boot.iso                             iso     iso          803209216
dir1:iso/rhel-server-7.9-x86_64-boot.iso                             iso     iso          635437056
dir1:iso/rhel-server-7.9-x86_64-dvd.iso                              iso     iso         4526702592
dir1:iso/S15Pup32-22.12.iso                                          iso     iso          401604608
dir1:iso/sparkylinux-2022.10-1-x86_64-mate.iso                       iso     iso         1972371456
dir1:iso/super_grub2_disk_hybrid_2.04s1.iso                          iso     iso           16361472
dir1:iso/supergrub2-2.04s2-beta2-i386_efi-CD.iso                     iso     iso           10766336
dir1:iso/supergrub2-2.04s2-beta2-i386_pc-CD.iso                      iso     iso            7610368
dir1:iso/supergrub2-2.04s2-beta2-multiarch-CD.iso                    iso     iso           16248832
dir1:iso/supergrub2-2.04s2-beta2-x86_64_efi-CD.iso                   iso     iso           11501568
dir1:iso/supergrub2-classic-2.06s2-beta1-multiarch-CD.iso            iso     iso           26804224
dir1:iso/supergrub2-classic-2.06s2-beta1-x86_64_efi-CD.iso           iso     iso           16769024
dir1:iso/systemrescue+zfs-10.02+2.2.2-amd64.iso                      iso     iso         1035993088
dir1:iso/systemrescue+zfs-7.01+2.0.0-amd64.iso                       iso     iso          815792128
dir1:iso/systemrescue-10.01-amd64.iso                                iso     iso          772800512
dir1:iso/systemrescue-10.02-amd64.iso                                iso     iso          800063488
dir1:iso/systemrescue-11.00-amd64.iso                                iso     iso          894435328
dir1:iso/systemrescue-8.06-amd64.iso                                 iso     iso          780140544
dir1:iso/systemrescue-9.04-amd64.iso                                 iso     iso          752877568
dir1:iso/systemrescue-9.05-amd64.iso                                 iso     iso          765460480
dir1:iso/systemrescue-9.06-amd64.iso                                 iso     iso          784334848
dir1:iso/systemrescuecd-amd64-6.1.8.iso                              iso     iso          716177408
dir1:iso/titanlinux-1.2.1-cronus-stable.iso                          iso     iso         2734686208
dir1:iso/TODO-TEST-debian-bookworm-DI-rc3-amd64-netinst.iso          iso     iso          773849088
dir1:iso/ubcd538.iso                                                 iso     iso          728922112
dir1:iso/ubcd539.iso                                                 iso     iso          842489856
dir1:iso/ubuntu-20.04.1-desktop-amd64.iso                            iso     iso         2785017856
dir1:iso/ubuntu-20.04.6-desktop-amd64.iso                            iso     iso         4351463424
dir1:iso/ubuntu-22.04-desktop-amd64.iso                              iso     iso         3654957056
dir1:iso/ubuntu-22.04.3-live-server-amd64.iso                        iso     iso         2133391360
dir1:iso/ubuntu-mate-20.04.2-desktop-amd64.iso                       iso     iso         2617245696
dir1:iso/ultimate-arch-2022.12.31-x86_64.iso                         iso     iso         3896848384
dir1:iso/ultimate-edition-5.8-x64-gamers.iso                         iso     iso         4194246656
dir1:iso/ultimate-edition-6.7.1-x64-developer.iso                    iso     iso         4369268736
dir1:iso/ultimate-edition-7.1-x64.iso                                iso     iso         3877109760
dir1:iso/VeeamRecoveryMedia-v508-win7-P3300.iso                      iso     iso         1536163840
dir1:iso/VeeamRecoveryMedia_P2300M7.iso                              iso     iso         1349844992
dir1:iso/VeeamRecoveryMedia_PAVILIONWIN7.iso                         iso     iso         1208549376
dir1:iso/VeeamRecoveryMedia_W10DELLAPE6540.iso                       iso     iso          740098048
dir1:iso/VeeamRecoveryMedia_W10DLAP20H2.iso                          iso     iso          714735616
dir1:iso/VeeamRecoveryMedia_win10-vm-20h2.iso                        iso     iso          728956928
dir1:iso/VeeamRecoveryMedia_WIN11VM1IMC5.iso                         iso     iso          804716544
dir1:iso/virtio-win-0.1.240.iso                                      iso     iso          627519488
dir1:iso/virtio-win.iso                                              iso     iso          534818816
dir1:iso/void-live-x86_64-20230628-xfce.iso                          iso     iso         1031798784
dir1:iso/Win10_22H2_English_x64.iso                                  iso     iso         6115186688
dir1:iso/xubuntu-22.04-core-amd64.iso                                iso     iso         1235918848
dir1:iso/Zorin-OS-15.3-Core-64-bit--debian-ubuntu.iso                iso     iso         2363277312
dir1:iso/Zorin-OS-16-Core-64-bit-r1.iso                              iso     iso         2866102272
o local:
Volid                                                               Format  Type             Size VMID
local:backup/vzdump-lxc-110-2024_02_24-12_55_33.tar.zst             tar.zst backup      779211458 110
local:backup/vzdump-lxc-99998-2024_02_27-14_21_18.tar.zst           tar.zst backup      188528354 99998
local:iso/boot-repair-disk-64bit.iso                                iso     iso         922746880
local:iso/clonezilla-live-3.1.2-22-amd64.iso                        iso     iso         442499072
local:iso/debian-12.5.0-amd64-netinst.iso                           iso     iso         659554304
local:iso/devuan_daedalus_5.0.0_amd64_netinstall.iso                iso     iso         499908608
local:iso/devuan_daedalus_5.0.1_i386_netinstall.iso                 iso     iso         506265600
local:iso/Dr.Parted-Live24.03.1-amd64.iso                           iso     iso         725614592
local:iso/Dr.Parted-Live24.05-amd64.iso                             iso     iso         763363328
local:iso/gparted-live-1.4.0-6-amd64.iso                            iso     iso         507510784
local:iso/HBCD_PE_x64.iso                                           iso     iso        3099203584
local:iso/hrmpf-x86_64-6.1.3_1-20230105.iso                         iso     iso        1801322496
local:iso/ipxe-network-boot.iso                                     iso     iso           4194304
local:iso/kanotix64-silverfire-nightly-LXDE.iso                     iso     iso        2211446784
local:iso/kanotix64-slowfire-nightly-LXDE.iso                       iso     iso        2459959296
local:iso/KNOPPIX_V9.1DVD-2021-01-25-EN.iso                         iso     iso        4694753280
local:iso/lmde-6-cinnamon-64bit.iso                                 iso     iso        2690580480
local:iso/macos-monterey-install.iso                                iso     iso       17179869184
local:iso/netboot.xyz.iso                                           iso     iso           2390016
local:iso/openSUSE-Leap-15.5-NET-x86_64-Build491.1-Media.iso        iso     iso         212860928
local:iso/openSUSE-Tumbleweed-DVD-x86_64-Snapshot20240321-Media.iso iso     iso        4466933760
local:iso/openSUSE-Tumbleweed-NET-x86_64-Snapshot20240223-Media.iso iso     iso         289406976
local:iso/proxmox-ve_8.2-1.iso                                      iso     iso        1395881984
local:iso/pxe--netboot.xyz.iso                                      iso     iso           2428928
local:iso/refind-cd-0.14.0.2.iso                                    iso     iso          14983168
local:iso/rescatux-0.74.iso                                         iso     iso         747634688
local:iso/rescuezilla-2.2-64bit.hirsute.iso                         iso     iso         947429376
local:iso/supergrub2-2.04s2-beta2-i386_efi-CD.iso                   iso     iso          10766336
local:iso/supergrub2-2.04s2-beta2-i386_pc-CD.iso                    iso     iso           7610368
local:iso/supergrub2-2.04s2-beta2-multiarch-CD.iso                  iso     iso          16248832
local:iso/supergrub2-2.04s2-beta2-x86_64_efi-CD.iso                 iso     iso          11501568
local:iso/systemrescue+zfs-10.02+2.2.2-amd64.iso                    iso     iso        1035993088
local:iso/systemrescue-10.02-amd64.iso                              iso     iso         800063488
local:iso/systemrescue-11.00-amd64.iso                              iso     iso         894435328
local:iso/systemrescue-11.01-amd64.iso                              iso     iso         941621248
local:iso/ubcd539.iso                                               iso     iso         842489856
local:iso/ubuntu-22.04-desktop-amd64.iso                            iso     iso        3654957056
local:iso/ubuntu-24.04-desktop-amd64.iso                            iso     iso        6114656256
local:iso/VeeamRecoveryMedia_dellape6540win10.iso                   iso     iso         680591360
local:iso/virtio-win-0.1.240.iso                                    iso     iso         627519488
local:iso/wattOS-R13.iso                                            iso     iso        1547698176
local:iso/Win10_22H2_English_x64.iso                                iso     iso        6115186688
local:iso/Win11_22H2_English_x64v1.iso                              iso     iso        5557432320
local:iso/wsusoffline-w100-x64--20220820.iso                        iso     iso        9002252288
local:iso/xubuntu-22.04-core-amd64.iso                              iso     iso        1235918848
local:vztmpl/debian-11-turnkey-ansible_17.1-1_amd64.tar.gz          tgz     vztmpl      551590459
local:vztmpl/debian-11-turnkey-fileserver_17.1-1_amd64.tar.gz       tgz     vztmpl      389394152
local:vztmpl/debian-11-turnkey-mediaserver_17.1-1_amd64.tar.gz      tgz     vztmpl      612997331
local:vztmpl/debian-12-turnkey-bookstack_18.0-1_amd64.tar.gz        tgz     vztmpl      315306555
local:vztmpl/devuan-4.0-standard_4.0_amd64.tar.gz                   tgz     vztmpl      110441721
local:vztmpl/almalinux-9-default_20221108_amd64.tar.xz              txz     vztmpl      102624500
local:vztmpl/devuan-daedalus-5-amd64.tar.xz                         txz     vztmpl       81356456
local:vztmpl/opensuse-15.4-default_20221109_amd64.tar.xz            txz     vztmpl       41548280
local:vztmpl/opensuse-15.5-default_20231118_amd64.tar.xz            txz     vztmpl       41314120
local:vztmpl/suse-tumbleweed-20240219-desktop-kde.tar.xz            txz     vztmpl       42240476
local:vztmpl/debian-11-standard_11.7-1_amd64.tar.zst                tzst    vztmpl      122247556
local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst                tzst    vztmpl      126129049
local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst            tzst    vztmpl      129824858
o local-lvm:
Volid                   Format  Type             Size VMID
local-lvm:vm-103-disk-0 raw     images    10737418240 103
local-lvm:vm-103-disk-2 raw     images     5477761024 103
local-lvm:vm-107-disk-0 raw     images        4194304 107
local-lvm:vm-107-disk-1 raw     images        4194304 107
local-lvm:vm-123-disk-0 raw     images    32212254720 123
local-lvm:vm-124-disk-0 raw     rootdir    5368709120 124
local-lvm:vm-125-disk-0 raw     images     4294967296 125
local-lvm:vm-125-disk-1 raw     images     5368709120 125
local-lvm:vm-126-disk-0 raw     images        4194304 126
o pbs-p2300m-laptop:
o sshfs-macpro-10g-sgtera2:
Volid                                                                             Format  Type             Size VMID
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-102-2024_02_15-03_00_00.tar.zst        tar.zst backup      852300917 102
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-105-2024_02_27-10_19_56.tar.zst        tar.zst backup      188480467 105
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-105-2024_04_06-16_31_47.tar.zst        tar.zst backup      211028680 105
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-105-2024_04_15-09_26_21.tar.zst        tar.zst backup      210709472 105
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-110-2024_04_20-00_15_05.tar.zst        tar.zst backup    83294944746 110
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-110-2024_05_04-00_15_08.tar.zst        tar.zst backup    83294940097 110
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-113-2024_04_20-01_06_05.tar.zst        tar.zst backup     1424109077 113
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-113-2024_05_04-01_09_28.tar.zst        tar.zst backup     1424102513 113
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-114-2024_04_05-21_47_55.tar.zst        tar.zst backup      231805356 114
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-114-2024_04_20-01_07_13.tar.zst        tar.zst backup     1482161992 114
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-114-2024_05_04-01_10_33.tar.zst        tar.zst backup     1482159778 114
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-118-2024_05_04-01_11_33.tar.zst        tar.zst backup      538986043 118
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-122-2024_04_20-01_11_09.tar.zst        tar.zst backup      231760711 122
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-122-2024_05_04-01_12_26.tar.zst        tar.zst backup      231753239 122
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-123-2024_04_06-16_38_27.tar.zst        tar.zst backup      175747571 123
sshfs-macpro-10g-sgtera2:backup/vzdump-lxc-99998-2024_03_15-10_02_00.tar.zst      tar.zst backup      188663422 99998
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-104-2024_02_19-03_00_09.vma.zst       vma.zst backup     1701954870 104
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-104-2024_04_11-03_00_05.vma.zst       vma.zst backup     2739819500 104
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-104-2024_04_12-03_00_07.vma.zst       vma.zst backup     2752459855 104
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-104-2024_04_13-03_00_02.vma.zst       vma.zst backup     2760584662 104
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-104-2024_04_14-03_00_05.vma.zst       vma.zst backup     2776942703 104
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-106-2024_02_15-03_05_33.vma.zst       vma.zst backup    23273720488 106
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-108-2024_04_06-14_39_13.vma.zst       vma.zst backup     7981255314 108
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-109-2024_02_16-03_08_01.vma.zst       vma.zst backup     1026233618 109
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-109-2024_02_17-03_07_47.vma.zst       vma.zst backup     1046183119 109
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-109-2024_02_18-03_07_57.vma.zst       vma.zst backup     1074031435 109
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-109-2024_02_19-03_08_21.vma.zst       vma.zst backup     1095212618 109
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-111-2024_02_17-03_09_11.vma.zst       vma.zst backup      618743838 111
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-111-2024_02_18-03_09_23.vma.zst       vma.zst backup      616108535 111
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-111-2024_02_19-03_09_53.vma.zst       vma.zst backup      615770304 111
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-112-2024_02_20-00_37_45.vma.zst       vma.zst backup    19377615868 112
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-115-2024_04_01-15_22_50.vma.zst       vma.zst backup     5483250464 115
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-117-2024_02_22-10_55_20.vma.zst       vma.zst backup    67889353524 117
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-120-2024_03_22-20_26_09.vma.zst       vma.zst backup     2110569773 120
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-120-2024_03_23-00_58_42.vma.lzo       vma.lzo backup    44302266319 120
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-121-2024_04_14-17_43_09.vma.zst       vma.zst backup     5759093480 121
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-122-2024_04_06-19_08_27.vma.zst       vma.zst backup      632590446 122
sshfs-macpro-10g-sgtera2:backup/vzdump-qemu-9999-2024_03_15-09_58_37.vma.zst      vma.zst backup      605259353 9999
sshfs-macpro-10g-sgtera2:vztmpl/debian-11-turnkey-mediaserver_17.1-1_amd64.tar.gz tgz     vztmpl      612997331
o tosh10-xfs-multi:
Volid                                                               Format  Type              Size VMID
tosh10-xfs-multi:104/vm-104-disk-0.qcow2                            qcow2   images     21474836480 104
tosh10-xfs-multi:109/vm-109-disk-0.qcow2                            qcow2   images     23622320128 109
tosh10-xfs-multi:116/vm-116-disk-0.qcow2                            qcow2   images    515396075520 116
tosh10-xfs-multi:120/vm-120-disk-0.raw                              raw     images    137438953472 120
tosh10-xfs-multi:126/vm-126-disk-0.qcow2                            qcow2   images    274877906944 126
tosh10-xfs-multi:backup/vzdump-qemu-125-2024_04_19-14_27_49.vma.zst vma.zst backup            9383 125
o zfs1:
Volid                                Format  Type              Size VMID
zfs1:subvol-110-disk-0               subvol  rootdir   252329328640 110
zfs1:subvol-122-disk-0               subvol  rootdir     6442450944 122
zfs1:vm-101-disk-0                   raw     images     22548578304 101
zfs1:vm-102-disk-0                   raw     images     22548578304 102
zfs1:vm-102-state-suspend-2024-03-12 raw     images      9114222592 102
zfs1:vm-103-disk-0                   raw     images    107374182400 103
zfs1:vm-115-disk-0                   raw     images    137438953472 115
zfs1:vm-115-disk-1                   raw     images    274877906944 115
zfs1:vm-121-disk-0                   raw     images    268435456000 121
zfs1:vm-121-disk-1                   raw     images    537944653824 121
o zfs2nvme:
Volid                      Format  Type             Size VMID
zfs2nvme:subvol-118-disk-0 subvol  rootdir    8589934592 118
zfs2nvme:vm-103-disk-0     raw     images    42949672960 103
zfs2nvme:vm-103-disk-1     raw     images     5477761024 103
zfs2nvme:vm-107-disk-0     raw     images    18113101824 107
zfs2nvme:vm-108-disk-0     raw     images     9126805504 108
zfs2nvme:vm-112-disk-0     raw     images        1048576 112
zfs2nvme:vm-117-disk-0     raw     images        1048576 117
zfs2nvme:vm-117-disk-1     raw     images    26843545600 117
zfs2nvme:vm-120-disk-0     raw     images        1048576 120
zfs2nvme:vm-121-disk-0     raw     images        1048576 121
zfs2nvme:vm-127-disk-0     raw     images        1048576 127
o zfs3nvme1T:
Volid                        Format  Type             Size VMID
zfs3nvme1T:subvol-110-disk-1 subvol  rootdir   22548578304 110
zfs3nvme1T:subvol-113-disk-0 subvol  rootdir    4294967296 113
zfs3nvme1T:subvol-114-disk-0 subvol  rootdir    4294967296 114
zfs3nvme1T:subvol-118-disk-0 subvol  rootdir   53687091200 118
zfs3nvme1T:vm-103-disk-0     raw     images        1048576 103
zfs3nvme1T:vm-103-disk-1     raw     images    85899345920 103
zfs3nvme1T:vm-103-disk-2     raw     images     5476712448 103
zfs3nvme1T:vm-106-disk-0     raw     images     8589934592 106
zfs3nvme1T:vm-107-disk-0     raw     images    85899345920 107
zfs3nvme1T:vm-108-disk-1     raw     images    25769803776 108
zfs3nvme1T:vm-111-disk-0     raw     images    17179869184 111
zfs3nvme1T:vm-112-disk-0     raw     images    42949672960 112
zfs3nvme1T:vm-117-disk-0     raw     images    68157440000 117
zfs3nvme1T:vm-120-disk-0     raw     images    22548578304 120
zfs3nvme1T:vm-121-disk-0     raw     images    34359738368 121
o zst4-f4m8-multi:
Volid                                                              Format  Type             Size VMID
zst4-f4m8-multi:backup/vzdump-qemu-103-2024_04_06-01_32_39.vma     vma     backup    78214162432 103
zst4-f4m8-multi:backup/vzdump-qemu-103-2024_05_04-01_30_08.vma     vma     backup    76816627712 103
zst4-f4m8-multi:backup/vzdump-qemu-107-2024_03_02-10_54_42.vma     vma     backup    46680379904 107
zst4-f4m8-multi:backup/vzdump-qemu-107-2024_05_04-01_45_24.vma     vma     backup    45233411072 107
zst4-f4m8-multi:backup/vzdump-qemu-112-2024_03_02-10_45_55.vma     vma     backup    36522929664 112
zst4-f4m8-multi:backup/vzdump-qemu-112-2024_05_04-01_50_25.vma     vma     backup    32347459584 112
zst4-f4m8-multi:backup/vzdump-qemu-117-2024_04_06-01_44_17.vma     vma     backup    82718194176 117
zst4-f4m8-multi:backup/vzdump-qemu-117-2024_05_04-01_56_22.vma     vma     backup    82718194176 117
zst4-f4m8-multi:backup/vzdump-qemu-125-2024_04_20-14_15_21.vma.zst vma.zst backup     7531055168 125
o ztosh10:
Volid                   Format  Type              Size VMID
ztosh10:vm-100-disk-0   raw     images     22548578304 100
ztosh10:vm-112-disk-0   raw     images     85899345920 112
ztosh10:vm-112-fleece-0 raw     images     42949672960 112
ztosh10:vm-112-fleece-1 raw     images     85899345920 112
ztosh10:vm-115-disk-1   raw     images    274877906944 115
ztosh10:vm-115-disk-2   raw     images     32212254720 115
ztosh10:vm-115-disk-3   raw     images         1048576 115
ztosh10:vm-119-disk-0   raw     images     32904314880 119
ztosh10:vm-125-disk-0   raw     images    274877906944 125
ztosh10:vm-125-disk-1   raw     images         1048576 125
ztosh10:vm-127-disk-0   raw     images     34359738368 127
o ztosh10-multi:
Volid Format  Type      Size VMID

=====

# grep vm-112 proxmox-storage-report.log |column -t
zfs2nvme:vm-112-disk-0    raw  images  1048576      112
zfs3nvme1T:vm-112-disk-0  raw  images  42949672960  112
ztosh10:vm-112-disk-0     raw  images  85899345920  112
ztosh10:vm-112-fleece-0   raw  images  42949672960  112
ztosh10:vm-112-fleece-1   raw  images  85899345920  112

=====

# REF: https://stackoverflow.com/questions/25077709/shell-script-for-awk-print-divide-value-with-1024

# not perfect, but convert column 4 to MB for easier reading
# awk '{ MB = int($4/1024/1024); $4=MB"_MB"; print}' proxmox-storage-report.log |column -t |less
o                                                                                  Storage  dir1:                      0_MB
Volid                                                                              Format   Type                       0_MB       VMID
dir1:105/vm-105-disk-1.raw                                                         raw      rootdir                    2048_MB    105
dir1:backup/vzdump-lxc-102-2024_02_15-03_00_00.tar.zst                             tar.zst  backup                     812_MB     102
dir1:backup/vzdump-lxc-105-2024_05_05-03_02_03.tar.zst                             tar.zst  backup                     219_MB     105
dir1:backup/vzdump-lxc-105-2024_05_06-03_02_11.tar.zst                             tar.zst  backup                     219_MB     105
