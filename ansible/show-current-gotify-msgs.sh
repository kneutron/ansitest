#!/bin/sh

# Show all current gotify msgs

#mid=$1
mydt=$(date +%Y%M%d@%H:%M_%S)

sqlite3 -header -csv /data/gotify.db "SELECT id,message,title FROM messages;" #> ~/gotify-cur-messages-saved-$mydt.csv

#ls -lhrt ~/gotify*csv
