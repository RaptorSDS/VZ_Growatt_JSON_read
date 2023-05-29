#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#!/bin/bash
set -u
set -e

# Function to display script usage
usage() {
  echo "Usage: $0 <hostname> <reading1> <reading2> ..."
  exit 1
}

# Validate required arguments
if [ "$#" -lt 2 ]; then
  usage
fi

# Extract hostname
HOSTNAME="$1"
shift

# Extract readings
READINGS="$*"

URL="http://${HOSTNAME}/status"

#echo $URL

#get json
JSON=$(curl --connect-timeout 5 -s "$URL")

#first check status
STATUS=$(echo "$JSON" | jq '. | to_entries[0].value')

if [ "$STATUS" != 0 ]; then
  # process json
  for READING in $READINGS; do
    OUTPUT=$(echo "$JSON" | jq -r --arg readings "$READING" '.[$readings]')
    printf "%s = %s\n" "$READING" "$OUTPUT"
  done
#else
  #echo "Inverter status is not 1"
fi
