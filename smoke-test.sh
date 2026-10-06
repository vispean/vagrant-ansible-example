#!/usr/bin/env bash
# Smoke-Test: prüft die Pflichtdienste der Umgebung vom Host aus.
# Grundlage für die stündliche Verfügbarkeitsprüfung am Hackathon.
# Rückgabe 0 = alle Pflichtdienste OK, sonst Anzahl Fehler.
set -u

WEB=192.168.56.11
DB=192.168.56.12
BASTION=192.168.56.13
fehler=0

ok()   { printf '  [ OK ]  %s\n' "$1"; }
fail() { printf '  [FAIL]  %s\n' "$1"; fehler=$((fehler+1)); }

port_offen() {  # host port
  timeout 3 bash -c ">/dev/tcp/$1/$2" 2>/dev/null
}

echo "== web01 ($WEB) : Webserver + CMS =="
if curl -fsSL --max-time 5 "http://$WEB/" -o /dev/null; then
  ort=$(curl -fsSL --max-time 5 "http://$WEB/" | grep -io 'wordpress' | head -n1)
  if [ -n "$ort" ]; then ok "HTTP 200, WordPress erkannt"; else ok "HTTP 200 (CMS-Inhalt nicht eindeutig)"; fi
else
  fail "HTTP auf web01 nicht erreichbar"
fi

echo "== db01 ($DB) : MariaDB =="
if port_offen "$DB" 3306; then ok "MariaDB-Port 3306 offen"; else fail "MariaDB-Port 3306 zu"; fi

echo "== bastion01 ($BASTION) : SSH + Samba =="
if port_offen "$BASTION" 22;  then ok "SSH-Port 22 offen";   else fail "SSH-Port 22 zu";   fi
if port_offen "$BASTION" 445; then ok "Samba-Port 445 offen"; else fail "Samba-Port 445 zu"; fi
if command -v smbclient >/dev/null 2>&1; then
  if smbclient -L "//$BASTION" -N 2>/dev/null | grep -q 'Kunden'; then
    ok "Samba-Freigabe 'Kunden' sichtbar"
  else
    echo "  [INFO] Freigabe 'Kunden' nicht anonym sichtbar (Auth nötig) – Port-Check zählt"
  fi
fi

echo
if [ "$fehler" -eq 0 ]; then
  echo "ERGEBNIS: alle Pflichtdienste OK"
else
  echo "ERGEBNIS: $fehler Pflichtdienst(e) NICHT OK"
fi
exit "$fehler"
