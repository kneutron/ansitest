#!/bin/bash

lvs|grep susp
#vm-108-state-suspend-2025-06-28                pve      Vwi-a-tz--  <12.49g data                       0.00   

time pvesm free local-lvm:vm-108-state-suspend-2025-06-28
date

# cannot del from gui
