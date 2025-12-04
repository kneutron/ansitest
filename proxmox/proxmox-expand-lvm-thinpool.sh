#!/bin/bash

exit;

#lvresize -L +300G vmdata/thinvol
#lvresize -A --verbose -r -L +100% pve/data
lvresize --verbose -r -l +100%FREE pvethin2 # pve/data

# REF: https://forum.proxmox.com/threads/how-to-extend-lvm-thin-pool.54900/

The error "specified % is unknown invalid arg" when using 

lvresize --verbose -r -l +99% 

occurs because the % syntax in the --extents option requires a
valid suffix to define the context for the percentage calculation.  The
correct syntax must include a suffix such as %FREE, %VG, or %PVS to specify
the source of the percentage value.  Using just +99% without a suffix is
invalid because the system cannot determine what 99% refers to.

To resolve this, you should use one of the valid percentage suffixes. For example:

    To allocate 99% of the free space in the volume group: lvresize -r -l +99%FREE

    To allocate 99% of the total size of the volume group: lvresize -r -l +99%VG

The -r flag automatically resizes the underlying filesystem after extending the logical volume, provided the filesystem supports online resizing.

The --verbose flag increases the output detail, which can help in diagnosing issues during execution.
