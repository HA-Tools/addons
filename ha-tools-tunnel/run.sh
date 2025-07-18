#!/bin/bash

CONFIG_PATH=/data/frpc.ini

# Hole Variablen von Add-on-Options (Home Assistant setzt diese als Umgebungsvariablen)
export server_addr="$SERVER_ADDR"
export server_port="$SERVER_PORT"
export subdomain="$SUBDOMAIN"

echo "Generiere frpc.ini mit:"
echo "  server_addr: $server_addr"
echo "  server_port: $server_port"
echo "  subdomain:   $subdomain"

# Erzeuge Konfiguration
envsubst < /frpc.ini.j2 > $CONFIG_PATH

# Starte frpc
exec frpc -c $CONFIG_PATH
