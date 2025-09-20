#!/bin/bash 

# for immich instance = blah
ip=192.168.1.241
#port=2283

curl -s -L -X GET "http://$ip:2283/api/jobs" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "x-api-key: REDACTED" \
|sed  's/}/}\n/g' 
#|grep 'active":1'
# sed = put in newlines for pretty-print
