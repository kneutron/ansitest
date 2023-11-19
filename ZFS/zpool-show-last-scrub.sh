#!/bin/bash

zpool status -v |egrep 'pool:|scan' #|less

exit;

# sample output
  pool: zint500
  scan: scrub repaired 0B in 00:48:16 with 0 errors on Thu Nov 16 00:49:16 2023
  pool: zsam53
  scan: scrub repaired 0B in 01:42:37 with 0 errors on Wed Nov 15 01:43:37 2023
  pool: ztoshtera6
  scan: scrub repaired 0B in 22:32:04 with 0 errors on Fri Nov 17 22:33:05 2023
