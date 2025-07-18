#!/bin/bash

CONFIG_PATH=/data/frpc.yaml

export SERVER_ADDR="${SERVER_ADDR}"
export SERVER_PORT="${SERVER_PORT}"
export SUBDOMAIN="${SUBDOMAIN}"

# Debug: Zeige Umgebungsvariablen
echo "FRPC wird gestartet mit:"
echo "  server_addr: $SERVER_ADDR"
echo "  server_port: $SERVER_PORT"
echo "  subdomain:   $SUBDOMAIN"

# Template verarbeiten
export SERVER_ADDR SERVER_PORT SUBDOMAIN
envsubst < /frpc.yaml.j2 > $CONFIG_PATH

# Start
exec frpc -c $CONFIG_PATH
