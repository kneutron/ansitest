#!/bin/bash

# REF: https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-c03113986

echo "$(date) - Rescanning scsi bus"
for hba in $(ls -1 /sys/class/scsi_host); do
  echo -e -n "$hba  \r"
  echo "- - -" > /sys/class/scsi_host/${hba}/scan
done
echo ''
