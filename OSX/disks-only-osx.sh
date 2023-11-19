#!/bin/bash

DBS=/var/run/disk/by-serial

# w/o partitions
ls -l $DBS |egrep -v 'disk.s|disk..s' |awk '{print $9,$10,$11}' |gsed 's#disk#disk #g' |sort -h -k 4 |column -t

exit;

# Sample output
ST3500418AS-5VMSTS             ->  /dev/disk  0
004-2E4164-Z521TR              ->  /dev/disk  1
Portable_SSD_T5-S49WNP0N12051  ->  /dev/disk  2
HDWR460UZSVB-13T0A01HF1        ->  /dev/disk  3


la $DBS |egrep -v 'disk.s|disk..s' |sort -h -k 11
drwxr-xr-x   7 root  daemon   224 Nov 17 23:43 ..
drwxr-xr-x  63 root  daemon  2016 Nov 17 22:42 .
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 APPLE_SSD_SM1024G-S32YNY0M200366 -> /dev/disk0
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 HGST_HUS726060ALE614-K8JAPRGN -> /dev/disk5
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 PSSD_T7_Shield-X17960CT0SNLS6S -> /dev/disk2
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 ST4000VN000-1H4168-Z3076XVL -> /dev/disk6
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 ST6000VN001-2BB186-ZR112FRW -> /dev/disk9
lrwxr-xr-x   1 root  daemon    10 Nov 17 22:42 TOSHIBA_HDWG11A-Y1A0A01AFBDG -> /dev/disk7
lrwxr-xr-x   1 root  daemon    11 Nov 17 22:42 ST4000VN000-2AH166-WDH0SB5N -> /dev/disk11
lrwxr-xr-x   1 root  daemon    11 Nov 17 22:42 ST4000VN008-2DR166-ZGY9F4M8 -> /dev/disk10
