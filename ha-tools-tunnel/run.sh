#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml

INSTANCE_ID=$(jq -r '.instance_id' "$OPTIONS_FILE")

# Finde den Home Assistant Container dynamisch
CONTAINER_ID=$(docker ps --filter "ancestor=homeassistant/home-assistant" --format "{{.ID}}" | head -n1)
if [ -z "$CONTAINER_ID" ]; then
  echo "Fehler: Home Assistant Container nicht gefunden!"
  exit 1
fi

# Extrahiere den HostPort für 8123/tcp
LOCAL_PORT=$(docker inspect "$CONTAINER_ID" \
  --format '{{(index .NetworkSettings.Ports "8123/tcp").0.HostPort}}')

if [ -z "$LOCAL_PORT" ]; then
  echo "Fehler: Port 8123/tcp nicht gemappt?"
  exit 1
fi

# Bereite FRP-Konfig
FRP_TYPE=http
cat > "$CONFIG_PATH" <<EOF
[common]
server_addr = tunnel.ha-tools.de
server_port = 7000
token = $INSTANCE_ID

[ha]
type = $FRP_TYPE
local_port = $LOCAL_PORT
subdomain = $INSTANCE_ID
EOF

exec frpc -c "$CONFIG_PATH"
