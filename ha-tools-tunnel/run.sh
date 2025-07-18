#!/usr/bin/env bash
set -e

echo "Teste Erreichbarkeit von HA (ignoriere HTTP‑Code 405)..."
# Variante A: einfach ohne -f
if ! curl -sI http://localhost:8123 >/dev/null 2>&1; then
  echo "ERROR: Kann Home Assistant auf localhost:8123 nicht erreichen!"
  exit 1
fi

OPTIONS_FILE=/data/options.json

# 1) Optionen aus JSON holen
SERVER_ADDR=$(jq -r '.server_addr' "$OPTIONS_FILE")
SERVER_PORT=$(jq -r '.server_port' "$OPTIONS_FILE")
SUBDOMAIN=$(jq -r '.subdomain' "$OPTIONS_FILE")

echo "FRPC wird gestartet mit:"
echo "  SERVER_ADDR: $SERVER_ADDR"
echo "  SERVER_PORT: $SERVER_PORT"
echo "  SUBDOMAIN:   $SUBDOMAIN"

# 2) frpc.yaml generieren
CONFIG_PATH=/data/frpc.yaml
cat > "$CONFIG_PATH" <<EOF
serverAddr: "${SERVER_ADDR}"
serverPort: ${SERVER_PORT}

proxies:
  - name: ha-ui
    type: http
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
