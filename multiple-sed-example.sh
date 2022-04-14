#!/bin/bash

# convert short disk names to long OTF, should also work fine with zpool iostat
zpool status -v \
 |awk 'NF>0' \
 |sed 's/sdp/ata-ST4000VN000-1H4168_Z3073Z7/;s/sdo/ata-ST4000VN000-1H4168_Z3076XV/;s/sdn/ata-ST4000VN008-2DR166_ZDHB3DR/;s/sdm/ata-ST4000VN008-2DR166_ZDHB41B/;s/sdd/ata-ST4000VN008-2DR166_ZDHBCLL/;s/sdc/ata-ST4000VN008-2DR166_ZDHBDGP/'

exit;

Given:

  pool: zseatera4
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        zseatera4   ONLINE       0     0     0
          raidz2-0  ONLINE       0     0     0
            sdc     ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sdp     ONLINE       0     0     0
            sdo     ONLINE       0     0     0
            sdn     ONLINE       0     0     0
            sdm     ONLINE       0     0     0
errors: No known data errors

Outputs:

  pool: zseatera4
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        zseatera4   ONLINE       0     0     0
          raidz2-0  ONLINE       0     0     0
            ata-ST4000VN008-2DR166_ZDHBDGP     ONLINE       0     0     0
            ata-ST4000VN008-2DR166_ZDHBCLL     ONLINE       0     0     0
            ata-ST4000VN000-1H4168_Z3073Z7     ONLINE       0     0     0
            ata-ST4000VN000-1H4168_Z3076XV     ONLINE       0     0     0
            ata-ST4000VN008-2DR166_ZDHB3DR     ONLINE       0     0     0
            ata-ST4000VN008-2DR166_ZDHB41B     ONLINE       0     0     0
errors: No known data errors
