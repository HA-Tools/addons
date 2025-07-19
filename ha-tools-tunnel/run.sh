#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml

INSTANCE_ID=$(jq -r '.instance_id' "$OPTIONS_FILE")

# Hole Port & SSL Info via Supervisor API
HTTP_INFO=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/core/api/http)
LOCAL_PORT=$(echo "$HTTP_INFO" | jq -r '.server_port')
USE_SSL=$(echo "$HTTP_INFO" | jq -r '.use_ssl')

# Setze Protokoll basierend auf SSL
FRP_TYPE=http
[ "$USE_SSL" == "true" ] && FRP_TYPE=https

# Schreibe frpc.yaml
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

# Starte frpc
exec frpc -c "$CONFIG_PATH"
