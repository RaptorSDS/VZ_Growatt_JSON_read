# VZ_Growatt_JSON_read

![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)
![Volkszähler](https://img.shields.io/badge/Volksz%C3%A4hler-Middleware-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)

Bash-Skripte, die den JSON-Statusblock eines **Growatt-Wechselrichters** über einen umgeflashten WiFi-Stick auslesen und die Werte an die **[Volkszähler](https://volkszaehler.org)**-Datenbank übergeben.

Zwei Varianten stehen zur Verfügung:

| Variante | Skript | Funktionsweise |
|---|---|---|
| **1 – Cron** | `Growatt_JSON_read.sh` | Liest den Wechselrichter per Cron-Job aus und schreibt direkt per HTTP in die Middleware |
| **2 – vzlogger exec** *(empfohlen)* | `growatt_json_exec.sh` | Wird vom `vzlogger` über das `exec`-Protokoll aufgerufen und gibt `Name = Wert` aus |

---

## Inhalt

- [Voraussetzungen](#voraussetzungen)
- [JSON-Daten prüfen](#json-daten-prüfen)
- [Installation](#installation)
- [Variante 1: Cron-Job](#variante-1-cron-job)
- [Variante 2: vzlogger exec](#variante-2-vzlogger-exec)
- [Lizenz](#lizenz)

---

## Voraussetzungen

**Hardware**

- Growatt-Wechselrichter (getestet: **Growatt 600TL-X**, einphasig, Modbus v1.24)
- Ein WiFi-Stick mit der Firmware **[otti/Growatt_ShineWiFi-S](https://github.com/otti/Growatt_ShineWiFi-S)**, z. B.:
  - ShineWiFi-X oder ShineWiFi-S (umgeflasht)
  - Wemos D1 mini (CH340)
  - NodeMCU ESP32-S (CH340)

**Software**

- Volkszähler-Installation (Middleware erreichbar)
- `bash`, `curl`
- Variante 1: `wget`
- Variante 2: `jq` und `vzlogger`

```bash
sudo apt install curl wget jq
```

---

## JSON-Daten prüfen

Bevor du etwas konfigurierst, rufe einmal den JSON-Datenblock des Sticks im Browser oder per `curl` ab, um zu sehen, welche Werte dein Wechselrichter bereitstellt:

```bash
curl http://<IP-des-Sticks>/status
```

Typische Felder sind z. B. `InverterStatus`, `TotalGenerateEnergy`, `TodayGenerateEnergy` und `OutputPower`.
Der Stick aktualisiert die JSON-Daten etwa **alle 5 Sekunden**.

> [!NOTE]
> Beide Skripte senden bzw. liefern nur Daten, wenn der Wechselrichter-Status **ungleich 0** ist (Wechselrichter betriebsbereit).

---

## Installation

```bash
git clone https://github.com/RaptorSDS/VZ_Growatt_JSON_read.git
cd VZ_Growatt_JSON_read
chmod +x Growatt_JSON_read.sh growatt_json_exec.sh
```

---

## Variante 1: Cron-Job

Das Skript liest den Wechselrichter aus und schreibt den **Gesamtzählerstand** sowie die **aktuelle Leistung** per HTTP-Aufruf direkt in die Middleware.

### 1. Skript anpassen

```bash
nano Growatt_JSON_read.sh
```

Passe folgende Variablen an deine Umgebung an:

| Variable | Bedeutung |
|---|---|
| `host_pv` | IP-Adresse des WiFi-Sticks |
| `host_db` | IP-Adresse des Volkszähler-Servers |
| `UUID1` | Kanal-UUID für den Zählerstand (`TotalGenerateEnergy`) |
| `UUID2` | Kanal-UUID für die Leistung (`OutputPower`) |

Bei Bedarf können auch die Namen der JSON-Objekte angepasst werden.
Mit `#` auskommentierte Zeilen dienen zum Debuggen oder als Vorlage für weitere Kanäle (z. B. `TodayGenerateEnergy`).

### 2. Cron-Job einrichten

```bash
crontab -e
```

Beispiel für einen Raspberry Pi mit einem Intervall von 1 Minute:

```cron
*/1 * * * * /bin/bash /home/pi/VZ_Growatt_JSON_read/Growatt_JSON_read.sh
```

> [!TIP]
> Durch das minimale Cron-Intervall von 1 Minute ist die Darstellung des Zählerstands eher grob. Für eine feinere Auflösung ist [Variante 2](#variante-2-vzlogger-exec) besser geeignet.

---

## Variante 2: vzlogger exec

In diesem Skript sind **keine Anpassungen** nötig – alle Optionen werden beim Aufruf übergeben:

```text
growatt_json_exec.sh <IP> <Reading1> [Reading2] ...
```

Es werden alle Readings ausgegeben, die im JSON-Datenblock vorhanden sind.
Beispielausgabe:

```console
$ ./growatt_json_exec.sh 192.168.1.50 TotalGenerateEnergy OutputPower
TotalGenerateEnergy = 1234.5
OutputPower = 312.4
```

### 1. Skript an einen festen Ort kopieren

```bash
sudo mkdir -p /etc/growatt
sudo cp growatt_json_exec.sh /etc/growatt/
```

### 2. Kanäle im Volkszähler-Frontend anlegen

Lege für jedes Reading einen Kanal an und notiere dir die jeweilige UUID.

### 3. vzlogger konfigurieren

Füge in der `vzlogger.conf` unter `meters` folgenden Block hinzu und passe IP und UUIDs an:

```json
{
  "enabled": true,
  "allowskip": true,
  "interval": 60,
  "aggtime": -1,
  "aggfixedinterval": false,
  "protocol": "exec",
  "command": "/etc/growatt/growatt_json_exec.sh 192.168.x.xx TotalGenerateEnergy OutputPower",
  "format": "$i = $v",
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
  ]
}
```

| Einstellung | Wirkung |
|---|---|
| `interval: 60` | Der Wechselrichter wird alle 60 s abgefragt |
| `duplicates: 3600` | Der Zählerstand wird auf Duplikate geprüft und spätestens nach 3600 s erneut geschrieben, auch ohne neuen Wert |
| `identifier` | Muss exakt dem Namen des Readings im JSON entsprechen |

### 4. vzlogger neu starten

```bash
sudo systemctl restart vzlogger
```

---

## Lizenz

Veröffentlicht unter der [MIT-Lizenz](LICENSE).
© 2023 Tobias Baumann aka **RaptorSDS**
