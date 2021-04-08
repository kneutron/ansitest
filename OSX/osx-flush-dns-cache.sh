#!/bin/bash
dscacheutil -flushcache && killall -HUP mDNSResponder
say cache flushed

# REF: https://macpaw.com/how-to/el-capitan-slow-5-tips-to-speed-up-osx-10-11

