#!/bin/bash

CONFIG_PATH=/data/frpc.ini

# Rendere Config aus Jinja2 Template
echo "Generiere FRPC-Konfiguration..."
mkdir -p /data
envsubst < /frpc.ini.j2 > $CONFIG_PATH

echo "Starte frpc..."
exec frpc -c $CONFIG_PATH
