#!/bin/bash

# Scenario - reinstalled pve, no full backup of VMs but the disks are still available on storage

qm rescan

exit;

# REF: https://www.reddit.com/r/Proxmox/comments/1cqr0xj/pve_host_installed_on_new_disk_how_to_import_vms/

So I installed PVE host on a new disk and imported the ZFS disk with all my
VMs to this new installation.  I can see the disk and VM disks showing under
storage.  So far so good.

Now how do I go about restoring the VM? I dont have whole backup

=====

narrateourale

Did you back up the VM configs located at /etc/pve/qemu-config?

If not, then create new VMs, match the VMID to the old one.  Dont create
any disk and once the VM (or all) are created, run qm rescan on the shell. 
It will search for disk images on the configured storages that match the
VMID.  For each found disk image, it will create a new "unusedX" disk entry
in the VM config.

You can then edit these disks and finish the configuration.  Dont forget to
update the boot order in the options of the VM!

If your VMs have EFI and TPM disks, it can be a bit messy and you might want
to create them from scratch.  Otherwise, editing the config files directly
to change them from "unused0" to whatever config key is needed might be
quicker.
