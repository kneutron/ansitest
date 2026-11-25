#!/bin/sh

# Save 1 message with ID number as arg1 to dated csv

mid=$1
mydt=$(date +%Y%M%d@%H:%M_%S)

sqlite3 -header -csv /data/gotify.db "SELECT id,message,title,date FROM messages WHERE id = $mid;" > ~/gotify-messages-saved-$mydt.csv

ls -lhrt ~/gotify*csv
