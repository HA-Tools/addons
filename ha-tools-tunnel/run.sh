#!/usr/bin/env bash
set -euo pipefail

# Optionen
OPTIONS_FILE=/data/options.json
FRPC_CONFIG=/data/frpc.yaml

INSTANCE_ID=$(jq -r '.instance_id' "$OPTIONS_FILE")

# Prüfe Token
if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
  echo "Fehler: SUPERVISOR_TOKEN fehlt!"
  exit 1
fi

# Supervisor-API-Call
HTTP_INFO=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    http://supervisor/core/api/http)

# Prüfen auf gültiges JSON
if ! echo "$HTTP_INFO" | jq empty >/dev/null 2>&1; then
  echo "Fehler: Supervisor-Antwort kein gültiges JSON:"
  echo "$HTTP_INFO"
  exit 1
fi

# Werte extrahieren
LOCAL_PORT=$(echo "$HTTP_INFO" | jq -r '.server_port')
USE_SSL=$(echo "$HTTP_INFO" | jq -r '.use_ssl')

# FRP-Protokoll wählen
FRP_TYPE=http
[ "$USE_SSL" = "true" ] && FRP_TYPE=https

# FRP-Konfig erstellen
cat > "$FRPC_CONFIG" <<EOF
[common]
server_addr = tunnel.ha-tools.de
server_port = 7000
token = $INSTANCE_ID

[ha]
type = $FRP_TYPE
local_port = $LOCAL_PORT
subdomain = $INSTANCE_ID
EOF

exec frpc -c "$FRPC_CONFIG"
