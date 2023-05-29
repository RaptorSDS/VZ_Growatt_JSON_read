# VZ_Growatt_JSON_read
bash script for read json and insert into VZ Database

need is a mod ShineStick_X or ShineStick_S 
also possible D1 mini (ch340) and NodeMCU S32 (ch340)

modded with 
https://github.com/otti/Growatt_ShineWiFi-S
==== Möglichkeit 1 CRON ====

Bitte über <IP/status> einmal die JSON Datenblock abfragen und schauen welche Daten der WR bereitstellt 

<note>der Nachfolgende Script ist für Modbus v1.24 und einem Growatt 600TL-x Einphasig ausgelegt </note>


  * Als nächstes Abfragedatei erstellen
 
  - git clone <code>sudo git clone https://github.com/RaptorSDS/VZ_Growatt_JSON_read.git</code>

  * Abfragedatei bearbeiten
<code>sudo nano Growatt_JSON_read.sh</code>

  * darin folgenden Inhalt hinzufügen/editieren

<note>Bitte IP , UUID und die Namen der Json Objekte an deine Gegebenheiten anpassen.</note>

Dieses Script sendet nur die aktuellen Zählerstand und zusätzlich die Leistung an die Middleware.\\
Zeilen mit "#" sind auskommentiert und können bei Bedarf genutzt werden für Debug oder um einen weitere Kanäle hinzuzufügen.
<note> aufgrund der langsamen auslesung vom Cron Job wie unten angegeben mit 1min Intervall ist die Darstellung des Zählerstandes nicht allzu gut </note>

  * Datei Speichern und ausführbar machen

   chmod +x Growatt_JSON_read.sh

  * Datei zu CRON hinzufügen (hier als Beispiel Raspberry Pi mit 1 minuten Intervall)

<code>*/1 * * * * /bin/bash /home/pi/Growatt_JSON_read.sh</code>

Grundsätzlich aktuallisiert der Wifi-Stick alle 5 sek die JSON-Daten  

==== Möglichkeit 2 vzlogger exec ====



Bitte über <IP/status> einmal die JSON Datenblock abfragen und schauen welche Daten der WR bereitstellt 

<note>der Nachfolgende Script ist für Modbus v1.24 und einem Growatt 600TL-x Einphasig ausgelegt </note>


  * Als nächstes Abfragedatei erstellen
    - git clone <code>sudo git clone https://github.com/RaptorSDS/VZ_Growatt_JSON_read.git</code>

<note> In der Datei sind keine Anpassungen notwendig alle Notigen Optionen werden von extern zu angegeben . \\
Folgende Optionen sind vorhanden ... exec.sh IP Reading1 Reading2 .... dabei werden alle Reading angenommen solange sie im JSON Datenblock vorhanden sind , der script beinhaltet eine Schutz nur wen der WR Status 1 = Betriebsbereit gesetzt hat werden daten ausgegebnen
</note>

  * Datei Speichern und ausführbar machen

   chmod +x Growatt_JSON_exec.sh
   
  * Die Datei kan jetzt an einen Bekannt Ort kopiert werden bsp /etc/growatt/

  * Als nächstes die Kanäle im Frontend erstellen

  * Folgende vzlogger config erstellen ändern
<code>
{
      "enabled": true,
      "allowskip": true,
      "interval": 60,
      "aggtime": -1,
      "aggfixedinterval": false,
      "channels": [
        {
          "api": "volkszaehler",
          "uuid": "e4f6a700-xxxxx",
          "identifier": "TotalGenerateEnergy",
          "middleware": "http://localhost/middleware.php",
          "aggmode": "none",
          "duplicates": 3600
        },
        {
          "api": "volkszaehler",
          "uuid": "35edd970-xxxxx",
          "identifier": "OutputPower",
          "middleware": "http://localhost/middleware.php",
          "aggmode": "avg",
          "duplicates": 0
        }
      ],
      "protocol": "exec",
      "command": "/etc/growatt/growatt_json_exec.sh 192.xxxx TotalGenerateEnergy OutputPower",
      "format": "$i = $v"
    },
 </code>
<note>Die Config ist so eingestellt das sie alle 60s den WR abfragt und an die DB Übergibt , Der Gesmt Zählerstand wir auf Duplikate kontrolliert und spätesten falls kein neuer Wert vorliegt nach 3600s erneut in die DB geschrieben</note>

  * vzlogger neu starten
