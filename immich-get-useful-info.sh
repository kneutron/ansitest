#!/bin/bash 

# REST API: https://immich.app/docs/api

# FY instance
ip=192.168.1.241
port=2283

function restofit () {
curl -s -L -X GET "http://$ip:$port/api/$1" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "x-api-key: REDACTED" \
|sed  's/}/}\n/g' 
}
# sed = put in newlines for pretty-print

#curl -s -L -X GET "http://$ip:2283/api/libraries" 
echo -n "Active jobs: "
restofit jobs |grep -c 'active":1'
echo -n "Inactive jobs: "
restofit jobs |grep -c 'active":0'
echo '====='
restofit server/about
restofit server/version
restofit server/statistics
restofit server/storage
restofit libraries
