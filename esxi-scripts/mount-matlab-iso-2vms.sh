#!/bin/bash

isopath=/vmfs/volumes/3aad31c1-9ba16698-b814-1402ecdbe850/ISOs
iso=matlab-R2023a_Update_8_Linux.iso

# mount iso to multiple vms
for vmid in 254 258 259 260 261 262 263 264 265 266; do
  echo "Mounting iso - $iso - on $vmid"
  vim-cmd vmsvc/device.connection $vmid ide0:0 $isopath/$iso
done

exit;

254    rhelbldr01                        [VMHOST02-LocalStorage] rhelbldr11/rhelbldr11.vmx  
258    rhelbldr02                        [VMHOST02-LocalStorage] rhelbldr12/rhelbldr12.vmx
259    rhelbldr03                        [VMHOST02-LocalStorage] rhelbldr13/rhelbldr13.vmx
260    rhelbldr04                        [VMHOST02-LocalStorage] rhelbldr14/rhelbldr14.vmx
261    rhelbldr05                        [VMHOST02-LocalStorage] rhelbldr15/rhelbldr15.vmx
262    rhelbldr06                        [VMHOST02-LocalStorage] rhelbldr16/rhelbldr16.vmx
263    rhelbldr07                        [VMHOST02-LocalStorage] rhelbldr17/rhelbldr17.vmx
264    rhelbldr08                        [VMHOST02-LocalStorage] rhelbldr18/rhelbldr18.vmx
265    rhelbldr09                        [VMHOST02-LocalStorage] rhelbldr19/rhelbldr19.vmx
266    rhelbldr10 			 [VMHOST02-LocalStorage] rhelbldr20/rhelbldr20.vmx

