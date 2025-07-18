#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml

# 1) Optionen aus JSON holen
SERVER_ADDR=$(jq -r '.server_addr' "$OPTIONS_FILE")
SERVER_PORT=$(jq -r '.server_port' "$OPTIONS_FILE")
SUBDOMAIN=$(jq -r '.subdomain'   "$OPTIONS_FILE")

echo "FRPC wird gestartet mit:"
echo "  SERVER_ADDR: $SERVER_ADDR"
echo "  SERVER_PORT: $SERVER_PORT"
echo "  SUBDOMAIN:   $SUBDOMAIN"

# 2) frpc.yaml via Here‑Doc schreiben
cat > "$CONFIG_PATH" <<EOF
serverAddr: "${SERVER_ADDR}"
serverPort: ${SERVER_PORT}

proxies:
  - name: ha-ui
    type: http
    localIp: "127.0.0.1"
    localPort: 8123
    customDomains:
      - "${SUBDOMAIN}.${SERVER_ADDR}"
    hostHeaderRewrite: "${SUBDOMAIN}.${SERVER_ADDR}"
EOF

echo "-------- Generierte frpc.yaml --------"
cat "$CONFIG_PATH"
echo "--------------------------------------"

# 3) frpc starten
exec frpc -c "$CONFIG_PATH"
