# VZ_Growatt_JSON_read
bash script for read json and insert into VZ Database

need is a mod ShineStick_X or ShineStick_S 
also possible D1 mini (ch340) and NodeMCU S32 (ch340)

modded with 
https://github.com/otti/Growatt_ShineWiFi-S


INSTALL    
  
    git clone https://github.com/RaptorSDS/VZ_Growatt_JSON_read.git

    nano Growatt_JSON_read.sh

Bitte IP Adressen, UUID an deine Gegebenheiten anpassen.


Dieses Script sendet nur die aktuelle Leistung an die Middleware und den Zählerstand.
Zeilen mit „#“ sind auskommentiert und können bei Bedarf genutzt werden für Debug oder um einen weitere Kanäle hinzuzufügen.

Datei Speichern und ausführbar machen

    chmod +x Growatt_JSON_read.sh

Datei zu CRON hinzufügen (hier als Beispiel Raspberry Pi mit 1 minuten Intervall)

   */1 * * * * /bin/bash /home/pi/Growatt_JSON_read.sh
