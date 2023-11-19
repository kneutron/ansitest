#!/bin/bash

zpool status -v |egrep 'pool:|scan' #|less