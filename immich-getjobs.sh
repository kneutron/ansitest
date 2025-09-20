#!/usr/bin/env bash5 

# FY
ip=192.168.1.241
#port=2283

curl -s -L -X GET "http://$ip:2283/api/jobs" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "x-api-key: rbcsie9T4DOkayXGQJO4wLFOgdkcx5vIZpD75goEU" \
|sed  's/}/}\n/g' 
#|grep 'active":1'
# put in newlines for pretty-print
