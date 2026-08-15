#!/bin/bash

# 2026.Aug kneutron, created with AI help after much head-beating and combining results // google / brave search

# Pull N random images / videos from Immich database to local storage for display; run again and they are deleted and replaced by another random set

# REQUIRES: curl jq, running immich instance, API key with Read Asset
# OPTIONAL: detox

# Should run on Linux and MacOS

# NOTE pull up destdir in file explorer / thumbnail mode after running, or load images as slideshow

# Configuration - TODO EDITME
IMMICH_URL="http://192.168.1.0:2283"       			# e.g., https://immich.example.com
API_KEY="UkGP4Rv2wn5aTrUcNIV1RaR0iSfl3AtGz6Zb"            	# Your Immich API Key
DEST_DIR="$HOME/tmpdel/immich-pulls"      			# Directory to save images
COUNT=18                         				# max Number of random images/movies to fetch

# Create destination directory
mkdir -pv "$DEST_DIR" 2>/dev/null

cd "$DEST_DIR" ||exit 44
/bin/rm -fv *.jpg *.JPG *.jpeg *.JPEG *.png *.gif *.avi *.webp *.mp4 *.webm *.wmv *.mkv *.mpg

# Fetch random assets into array
# Immich API v1.90+ returns an array for /random, but older versions or errors might differ.
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$IMMICH_URL/api/search/random" \
  -H "x-api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{\"count\": $COUNT}")

#echo "Number of items in curl RESPONSE: ${#RESPONSE[@]}"

# Separate body and HTTP code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check HTTP status
if [ "$HTTP_CODE" -ne 200 ]; then
    echo "Error: API request failed with status $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi

# Verify if response is a valid JSON array
# If it's a single object, wrap it in an array. If it's a string/error, fail.
if ! echo "$BODY" | jq -e 'type == "array"' > /dev/null 2>&1; then
    # Check if it's a single object (some API versions might return one item if count=1 requested but logic varies)
    if echo "$BODY" | jq -e 'type == "object"' > /dev/null 2>&1; then
        echo "Warning: Received a single object instead of an array. Wrapping for processing."
        BODY="[$BODY]"
    else
        echo "Error: Unexpected response format. Expected JSON array."
        echo "Response: $BODY"
        exit 1
    fi
fi

# Process each asset
start=1
echo "Max count: $COUNT"
echo "$BODY" | jq -c '.[]' | while read -r ASSET; do
    ASSET_ID=$(echo "$ASSET" | jq -r '.id')
    FILENAME=$(echo "$ASSET" | jq -r '.originalFileName // "image.jpg"')
    
    # Sanitize filename (remove spaces/special chars if necessary, optional)
    # FILENAME=$(echo "$FILENAME" | tr ' ' '_')

    if [ -z "$ASSET_ID" ] || [ "$ASSET_ID" == "null" ]; then
        echo "Skipping asset with missing ID."
        continue
    fi

#    echo "Downloading: $FILENAME (ID: $ASSET_ID)"
    # Download
    curl -s -X GET "$IMMICH_URL/api/assets/$ASSET_ID/original" \
      -H "x-api-key: $API_KEY" \
      -H "Accept: application/octet-stream" \
      -o "$DEST_DIR/$FILENAME"

    if [ $? -eq 0 ]; then
	echo -n $start..
	((start++))
	[ $start -gt $COUNT ] && break 	# otherwise it does 250 for some reason!
#        echo "Saved: $DEST_DIR/$FILENAME"
    else
        echo "Failed to download: $FILENAME"
    fi
done

echo ''
detox -v $PWD 2>&1 >/dev/null

# NOTE for osx use gdu
ls -lhrt $DEST_DIR |tail
du --apparent-size -s -h $DEST_DIR
echo "PK to rerun or ^C"
read -n 1
exec $0

# cre8 api key - immich topright icon, account settings \ api keys
