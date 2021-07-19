#!/bin/bash 

# Provide a QEMU-based VM for DRAID testing (NOTE slower than virtualbox)
# 2021 Dave Bechtel
# NOTE Ctrl+Alt+G to ungrab maus
# REF: https://qemu-project.gitlab.io/qemu/system/images.html#disk-images

# bash if not
if [ ! -e zfsfile01.raw.img ]; then
  echo "$(date) - Creating disks"
  for disk in $(seq -w 1 26); do
    time qemu-img create -f raw zfsfile$disk.raw.img 4G
  done
fi

# Provides port forward to ssh into guest
# 2xcpu, 8GB RAM, dvd mounted to copy data to DRAID pool instead of using network
# REQUIRES test-zfs-21-Draid-sata0-0.vdi vdisk to boot from!
qemu-system-x86_64 \
  test-zfs-21-Draid-sata0-0.vdi \
  -smp cpus=2, \
  -m 8G, \
  -cdrom /zmsata480/shrcompr/udfisos.iso \
  -display gtk,gl=on \
  -vga vmware \
  -netdev user,id=eth0,ipv6=off,net=10.1.0.0/8,hostfwd=tcp::32222-:22 \
    -device e1000,netdev=eth0,mac=52:54:58:76:54:32 \
  -drive file=zfsfile01.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile02.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile03.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile04.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile05.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile06.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile07.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile08.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile09.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile10.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile11.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile12.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile13.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile14.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile15.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile16.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile17.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile18.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile19.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile20.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile21.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile22.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile23.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile24.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile25.raw.img,format=raw,if=virtio,media=disk,cache=writeback \
    -drive file=zfsfile26.raw.img,format=raw,if=virtio,media=disk,cache=writeback 
         
# ssh localhost -p 32222  ## ssh to vm
# Difficulty: virtio drives have no disk/by-path and are vda..vdz
