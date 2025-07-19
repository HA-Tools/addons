#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml
DEFAULT_PORT=8123

INSTANCE_ID=$(jq -r '.instance_id' "$OPTIONS_FILE")

# Versuche, Port aus configuration.yaml zu lesen
if grep -sq "server_port:" /config/configuration.yaml; then
  LOCAL_PORT=$(grep -A1 "http:" /config/configuration.yaml | grep "server_port:" | awk '{print $2}')
else
  LOCAL_PORT=$DEFAULT_PORT
fi

echo "ℹ️  Verwende Port: ${LOCAL_PORT} (Auto-Erkennung)"

cat > "$CONFIG_PATH" <<EOF
serverAddr: "ui.ha-tools.com"
serverPort: 7000

proxies:
  - name: ha-ui
    type: http
    localIp: "127.0.0.1"
    localPort: ${LOCAL_PORT}
    customDomains:
      - "${INSTANCE_ID}.ui.ha-tools.com"
    hostHeaderRewrite: "${INSTANCE_ID}.ui.ha-tools.com"
EOF

exec frpc -c "$CONFIG_PATH"
