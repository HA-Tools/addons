#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml

# 1) Port‑Erkennung via grep
DEFAULT_PORT=8123
LOCAL_PORT=$DEFAULT_PORT
if [ -f /config/configuration.yaml ]; then
  DETECTED=$(grep -E '^[[:space:]]*server_port:[[:space:]]*[0-9]+' /config/configuration.yaml \
             | head -n1 \
             | sed -E 's/^[[:space:]]*server_port:[[:space:]]*([0-9]+).*/\1/')
  if [[ $DETECTED =~ ^[0-9]+$ ]]; then
    LOCAL_PORT=$DETECTED
  fi
fi
echo "Gefundener HA‑Port: $LOCAL_PORT (Fallback: 8123)"

# 2) Optionen aus JSON holen
SERVER_ADDR=$(jq -r '.server_addr' "$OPTIONS_FILE")
SERVER_PORT=$(jq -r '.server_port' "$OPTIONS_FILE")
TOKEN=$(jq -r '.token'       "$OPTIONS_FILE")
SUBDOMAIN=$(jq -r '.subdomain' "$OPTIONS_FILE")

echo "Starte FRPC mit:"
echo "  Server:    $SERVER_ADDR:$SERVER_PORT"
echo "  Token:     $TOKEN"
echo "  Subdomain: $SUBDOMAIN"
echo "  LocalPort: $LOCAL_PORT"

# 3) frpc.yaml erzeugen
cat > "$CONFIG_PATH" <<EOF
common:
  server_addr: $SERVER_ADDR
  server_port: $SERVER_PORT
  token:       $TOKEN
  tls_enable:  true

proxies:
  - name: ha-ui
    type: http
    localIp: "127.0.0.1"
    localPort: $LOCAL_PORT
    customDomains:
      - "${SUBDOMAIN}.ui.ha-tools.com"
    hostHeaderRewrite: "${SUBDOMAIN}.ui.ha-tools.com"
EOF

echo "-------- frpc.yaml --------"
cat "$CONFIG_PATH"
echo "---------------------------"

# 4) frpc starten
exec frpc -c "$CONFIG_PATH"
