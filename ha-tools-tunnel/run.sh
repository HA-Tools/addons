#!/bin/bash
set -e

CONFIG_PATH=/data/frpc.yaml

echo "FRPC wird gestartet mit:"
echo "  SERVER_ADDR: $SERVER_ADDR"
echo "  SERVER_PORT: $SERVER_PORT"
echo "  SUBDOMAIN:   $SUBDOMAIN"

# Ersetze nur diese drei Variablen – so bleibt nichts übrig
envsubst '$SERVER_ADDR $SERVER_PORT $SUBDOMAIN' < /frpc.yaml.j2 > $CONFIG_PATH

echo "-------- Generierte frpc.yaml --------"
cat $CONFIG_PATH
echo "--------------------------------------"

exec frpc -c $CONFIG_PATH
