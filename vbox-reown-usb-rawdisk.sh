#!/bin/bash

mydisk=/dev/disk1
myuser=dave

 sudo chown -R $myuser $mydisk*
 diskutil unmount $mydisk''s1

ls -al /dev/disk*
