#!/bin/bash

# works on ZFS and HFS+

# REF: https://en.wikipedia.org/wiki/Extended_file_attributes
#/Volumes/zsam52/shrcompr-zsam52 $ 
xattr -lv *
#testfile: xattrib1: test extended attrib

exit;

# Linux: use Extended attributes can be accessed and modified using the
getfattr and setfattr commands from the attr package on most
distributions.[16] The APIs are called getxattr and setxattr.
