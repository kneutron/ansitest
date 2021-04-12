#!/bin/bash

date
zpool iostat $1 -y -T d -v 5
