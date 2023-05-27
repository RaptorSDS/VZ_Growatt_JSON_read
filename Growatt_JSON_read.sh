#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#set -e bricht script ab wenn etwas nicht stimmt
set -e

# Script: Growatt_JSON_read.sh
# Author: Tobias Baumann aka RaptorSDS
# License: MIT
# with help of OpenAI GPT-3.5


#login daten
host_pv="192.168.x.xx"

UUID1="e4f6a700-xxx"
UUID2="35edd970-xxx"
host_db="192.168.x.xxx"
TOTAL=""
TODAY=""
ACTUAL=""
STATUS=""


#read inverter

JSON=$(curl -s $host_pv/status)

#extract ststus

STATUS=$(echo "$JSON" | grep -o '"InverterStatus":[0-9.]*' | cut -d ":" -f 2)

#when status 1  inverter ready use than the other value
if [ $STATUS != 0 ]; then

#extract other
TOTAL=$(echo "$JSON" | grep -o '"TotalGenerateEnergy":[0-9.]*' | cut -d ":" -f 2)
#TODAY=$echo "$JSON" | grep -o '"TodayGenerateEnergy":[0-9.]*' | cut -d ":" -f 2)
ACTUAL=$(echo "$JSON" | grep -o '"OutputPower":[0-9.]*' | cut -d ":" -f 2)


#an DB senden
#echo "SEND"
wget -O - -q "http://"$host_db"/middleware/data/"$UUID1".json?operation=add&value="$TOTAL""
wget -O - -q "http://"$host_db"/middleware/data/"$UUID2".json?operation=add&value="$ACTUAL""

fi

#printfor  Debug
#echo "Today:"$DAY
#echo "ACTUAL:"$ACTUAL
#echo "Total:"$TOTAL
