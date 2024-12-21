#!/bin/bash

vmid=100 # protect this one at all costs from oom-killer
[ "$1" = "" ] || vmid=$1

#declare -i pid # integer # not work if pid > 32768!
pid=$(ps ax |grep "kvm -id $vmid" |head -n 1 |awk '{print $1}')
[ "$pid" = "0" ] && exit 99;

ps $pid
echo "B4:"
cat /proc/${pid}/oom_score_adj
echo -1000 > /proc/${pid}/oom_score_adj
echo "After:"
cat /proc/${pid}/oom_score_adj

ps $pid

exit

# ps ax |grep 'kvm -id 100'
#3728112 ?        Sl     0:35 /usr/bin/kvm -id 100 -name pbs3-beelink,debug-threads=on -no-shutdown -chardev socket,id=qmp,path=/var/run/qemu-server/100.qmp,server=on,wait=off -mon chardev=qmp,mode=control -chardev socket,id=qmp-event,path=/var/run/qmeventd.sock,reconnect=5 -mon chardev=qmp-event,mode=control -pidfile /var/run/qemu-server/100.pid -daemonize -smbios type=1,uuid=18dfa228-cb4d-4ced-af3e-cc670d8e0cdc -drive if=pflash,unit=0,format=raw,readonly=on,file=/usr/share/pve-edk2-firmware//OVMF_CODE_4M.secboot.fd -drive if=pflash,unit=1,id=drive-efidisk0,format=raw,file=/dev/pve/vm-100-disk-0,size=540672 -smp 4,sockets=1,cores=4,maxcpus=4 -nodefaults -boot menu=on,strict=on,reboot-timeout=1000,splash=/usr/share/qemu-server/bootsplash.jpg -vnc unix:/var/run/qemu-server/100.vnc,password=on -cpu host,+aes,+kvm_pv_eoi,+kvm_pv_unhalt -m 8192 -object iothread,id=iothread-virtio0 -readconfig /usr/share/qemu-server/pve-q35-4.0.cfg -device vmgenid,guid=93a3b537-e419-430d-b3fa-bdc74260d91f -device usb-tablet,id=tablet,bus=ehci.0,port=1 -device virtio-vga,id=vga,bus=pcie.0,addr=0x1 -chardev socket,path=/var/run/qemu-server/100.qga,server=on,wait=off,id=qga0 -device virtio-serial,id=qga0,bus=pci.0,addr=0x8 -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 -device virtio-serial,id=spice,bus=pci.0,addr=0x9 -chardev spicevmc,id=vdagent,name=vdagent -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 -spice tls-port=61000,addr=127.0.0.1,tls-ciphers=HIGH,seamless-migration=on -iscsi initiator-name=iqn.1993-08.org.debian:01:bf9f50876e -drive if=none,id=drive-ide2,media=cdrom,aio=io_uring -device ide-cd,bus=ide.1,unit=0,drive=drive-ide2,id=ide2,bootindex=100 -drive file=/dev/zvol/zbeetle1t/vm-100-disk-0,if=none,id=drive-virtio0,cache=writeback,discard=on,format=raw,aio=io_uring,detect-zeroes=unmap -device virtio-blk-pci,drive=drive-virtio0,id=virtio0,bus=pci.0,addr=0xa,iothread=iothread-virtio0,bootindex=101 -netdev type=tap,id=net0,ifname=tap100i0,script=/var/lib/qemu-server/pve-bridge,downscript=/var/lib/qemu-server/pve-bridgedown,vhost=on,queues=4 -device virtio-net-pci,mac=BC:24:11:0A:A6:B6,netdev=net0,bus=pci.0,addr=0x12,id=net0,vectors=10,mq=on,packed=on,rx_queue_size=1024,tx_queue_size=256 -netdev type=tap,id=net1,ifname=tap100i1,script=/var/lib/qemu-server/pve-bridge,downscript=/var/lib/qemu-server/pve-bridgedown,vhost=on,queues=4 -device virtio-net-pci,mac=BC:24:11:AD:4F:88,netdev=net1,bus=pci.0,addr=0x13,id=net1,vectors=10,mq=on,packed=on,rx_queue_size=1024,tx_queue_size=256 -machine type=q35+pve0

# cat /proc/3728112/oom_score_adj 
0
# echo -1000 > /proc/3728112/oom_score_adj 
# cat /proc/3728112/oom_score_adj 
-1000

# REF: https://www.baeldung.com/linux/memory-overcommitment-oom-killer
