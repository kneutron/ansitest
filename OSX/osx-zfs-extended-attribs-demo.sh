#!/bin/bash

>sessionbuddymd5.txt 
for f in session*; do 
  md5sum "$f" >> sessionbuddymd5.txt
done
cat sessionbuddymd5.txt 

while read linein; do 
  part1=$(echo $linein |awk '{print $1}')
  part2=$(echo $linein |awk '{print $2}')
  echo $part1
  xattr -w com.myzfs.md5sum "$part1" "$part2"
done <sessionbuddymd5.txt 

xattr -l session* |grep myzfs |column -t

exit;

session_buddy_chrome-CANARY-export_2023_08_09_00_25_39.txt:         com.myzfs.md5sum:  6f2f771102fe9551d89f27a4e0ccd2ec
session_buddy_export_2023_06_24_14_22_56.csv:                       com.myzfs.md5sum:  a34ec8f64b550cf34c1da4d702c5a3a9
session_buddy_export_2023_06_24_14_23_06.html:                      com.myzfs.md5sum:  db829bf436f50e1bf028e74f205ad6ed
session_buddy_export_2023_08_09_00_53_23.csv:                       com.myzfs.md5sum:  5bb3b8b4174020cb1837075635156884
session_buddy_export_2023_08_09_00_53_37.html:                      com.myzfs.md5sum:  680128f7f3c2875223dd0998347c096d
session_buddy_export_2023_08_09_00_53_46.json:                      com.myzfs.md5sum:  7e06a2a6142ae8e1dc387a623eb4dad6
session_buddy_export_2023_08_09_00_54_30.csv:                       com.myzfs.md5sum:  e4a452d2b11012be328c21847c471735
session_buddy_export_2023_08_09_00_54_43.html:                      com.myzfs.md5sum:  b29bdf8b99fde3bb4a2302886cb8d941
session_buddy_export_2023_08_09_00_54_52.json:                      com.myzfs.md5sum:  13dc08ce07979bc67a4274da620829ce
session_buddy_export_2023_09_01_20_37_29.csv:                       com.myzfs.md5sum:  3121ee9721b0d4550e94f433cf02f68a
session_buddy_export_2023_09_01_20_37_39.html:                      com.myzfs.md5sum:  4bc36ec878b3286a8d45a32f4f3123ad
session_buddy_export_2023_09_01_20_37_45.json:                      com.myzfs.md5sum:  ba4fcbef008a948102f509d93bc939cd
session_buddy_export_2023_09_14_22_50_39.csv:                       com.myzfs.md5sum:  5dbd9687eb5831944d80b36afbe6ca55
session_buddy_export_2023_09_14_22_50_49.html:                      com.myzfs.md5sum:  10a8405f69e9e0c50e067bba89c0e6ae
session_buddy_export_2023_09_14_22_50_55.json:                      com.myzfs.md5sum:  4b908ec37665ac0eb604ef61e71400e9
session_buddy_export_chrome-CANARY-2023_08_09_00_26_07.csv:         com.myzfs.md5sum:  b97618377597d7176be794326be253de
session_buddy_export_chrome-CANARY-2023_08_09_00_26_24.html:        com.myzfs.md5sum:  c0bf5cfed5ea4234b813a2a2af3c0f18
session_buddy_export_chrome-stripped-down-2023_08_10_14_33_05.csv:  com.myzfs.md5sum:  4c20c732ac1d239f5606da2b5cef3453
sessionbuddymd5.txt:                                                com.myzfs.md5sum:  ad53b0fca1fdf0937fed4fe162184b92

cat sessionbuddymd5.txt 
6f2f771102fe9551d89f27a4e0ccd2ec  session_buddy_chrome-CANARY-export_2023_08_09_00_25_39.txt
a34ec8f64b550cf34c1da4d702c5a3a9  session_buddy_export_2023_06_24_14_22_56.csv
db829bf436f50e1bf028e74f205ad6ed  session_buddy_export_2023_06_24_14_23_06.html
5bb3b8b4174020cb1837075635156884  session_buddy_export_2023_08_09_00_53_23.csv
680128f7f3c2875223dd0998347c096d  session_buddy_export_2023_08_09_00_53_37.html
7e06a2a6142ae8e1dc387a623eb4dad6  session_buddy_export_2023_08_09_00_53_46.json
e4a452d2b11012be328c21847c471735  session_buddy_export_2023_08_09_00_54_30.csv
b29bdf8b99fde3bb4a2302886cb8d941  session_buddy_export_2023_08_09_00_54_43.html
13dc08ce07979bc67a4274da620829ce  session_buddy_export_2023_08_09_00_54_52.json
3121ee9721b0d4550e94f433cf02f68a  session_buddy_export_2023_09_01_20_37_29.csv
4bc36ec878b3286a8d45a32f4f3123ad  session_buddy_export_2023_09_01_20_37_39.html
ba4fcbef008a948102f509d93bc939cd  session_buddy_export_2023_09_01_20_37_45.json
5dbd9687eb5831944d80b36afbe6ca55  session_buddy_export_2023_09_14_22_50_39.csv
10a8405f69e9e0c50e067bba89c0e6ae  session_buddy_export_2023_09_14_22_50_49.html
4b908ec37665ac0eb604ef61e71400e9  session_buddy_export_2023_09_14_22_50_55.json
b97618377597d7176be794326be253de  session_buddy_export_chrome-CANARY-2023_08_09_00_26_07.csv
c0bf5cfed5ea4234b813a2a2af3c0f18  session_buddy_export_chrome-CANARY-2023_08_09_00_26_24.html
4c20c732ac1d239f5606da2b5cef3453  session_buddy_export_chrome-stripped-down-2023_08_10_14_33_05.csv
ad53b0fca1fdf0937fed4fe162184b92  sessionbuddymd5.txt
