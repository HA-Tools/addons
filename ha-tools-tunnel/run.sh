#!/bin/bash

CONFIG_PATH=/data/frpc.yaml

echo "FRPC wird gestartet mit:"
echo "  server_addr: $SERVER_ADDR"
echo "  server_port: $SERVER_PORT"
echo "  subdomain:   $SUBDOMAIN"

# explizite Ersetzung nur dieser Variablen:
envsubst '$SERVER_ADDR $SERVER_PORT $SUBDOMAIN' < /frpc.yaml.j2 > $CONFIG_PATH

echo "-------- Generierte frpc.yaml --------"
cat $CONFIG_PATH
echo "--------------------------------------"

exec frpc -c $CONFIG_PATH
