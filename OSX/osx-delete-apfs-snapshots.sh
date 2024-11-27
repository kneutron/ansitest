#!/bin/bash

tmutil listlocalsnapshots /Volumes/iscsi-macosmont12-davemacpro\ -\ Data
 
echo "SEE SOURCE"
exit;

# REF: https://www.google.com/search?q=monterey+delete+apfs+snapshot+commandline&num=10&sca_esv=fb0328165e44674a&rlz=1C5CHFA_enUS1050US1082&sxsrf=ADLYWIInlgRBKpZsnFqWtPdDbIPHgIviyw%3A1732216760856&ei=uIc_Z_z2M-Tfp84P5I6d0As&ved=0ahUKEwj8stGlku6JAxXk78kDHWRHB7oQ4dUDCBA&uact=5&oq=monterey+delete+apfs+snapshot+commandline&gs_lp=Egxnd3Mtd2l6LXNlcnAiKW1vbnRlcmV5IGRlbGV0ZSBhcGZzIHNuYXBzaG90IGNvbW1hbmRsaW5lMgcQIRigARgKMgcQIRigARgKMgcQIRigARgKMgcQIRigARgKMgcQIRigARgKSNcSULADWK8RcAF4AZABAZgBzAKgAfANqgEIMC4xMS4wLjG4AQPIAQD4AQGYAgygAugMwgIKEAAYsAMY1gQYR8ICBRAhGKABwgIFECEYqwLCAgUQIRifBcICBxAjGLACGCfCAggQABiABBiiBMICCBAAGKIEGIkFmAMAiAYBkAYIkgcIMS4xMC4wLjGgB4JC&sclient=gws-wiz-serp

  tmutil listlocalsnapshots
tmutil deletelocalsnapshots /Volumes/iscsi-macosmont12-davemacpro\ -\ Data 2024-10-08-181025
  tmutil deletelocalsnapshots /Volumes/iscsi-macosmont12-davemacpro\ -\ Data
  tmutil deletelocalsnapshots /Volumes/iscsi-macosmont12-davemacpro
  tmutil listlocalsnapshots /Volumes/iscsi-macosmont12-davemacpro\ -\ Data
  tmutil deletelocalsnapshots  2024-10-08-181025
