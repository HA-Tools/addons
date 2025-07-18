#!/bin/bash

CONFIG_PATH=/data/frpc.ini

export server_addr="${SERVER_ADDR}"
export server_port="${SERVER_PORT}"
export subdomain="${SUBDOMAIN}"

envsubst < /frpc.ini.j2 > $CONFIG_PATH
exec frpc -c $CONFIG_PATH
