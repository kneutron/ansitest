#!/bin/bash

pct mount $1 # number of LXC CTR

exit;

First, mount the LXC filesystems on the Proxmox host (LXC does not need to
be running, but can be).  Use `pct mount xxx` for each LXC.  It will tell
you the mount point, but it will be /var/lib/lxc/xxx/rootfs.  Now you can
manipulate the files in the LXC from the Proxmox host.  This includes all
mount points of the LXC overlaid properly.

Next, use `rsync` to copy the files from one LXC to another using the full
path to both rootfs`s.

Finally, recursively chown the files with a uid/gid offset of 100000 (the
offset used by unprivilaged LXCs).  Root in the container (uid 0) is uid
100000 on host.  I would just `chown -R 100000:100000` the entire directory
you just copied, so it`s accessible as root in the container, and then go
into the container and fix permissions within the container as container
root (using `chown -R user:group`)

When you are done, `pct unmount xxx`.

# REF: https://www.reddit.com/r/Proxmox/comments/1ch6555/most_efficient_way_to_copy_data_from_privileged/