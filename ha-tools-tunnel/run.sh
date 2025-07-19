#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=/data/options.json
CONFIG_PATH=/data/frpc.yaml

LOCAL_PORT=$(jq -r '.local_port' "$OPTIONS_FILE")
INSTANCE_ID=$(jq -r '.instance_id' "$OPTIONS_FILE")

# 2) frpc.yaml via Here‑Doc schreiben
cat > "$CONFIG_PATH" <<EOF
serverAddr: "ui.ha-tools.com"
serverPort: 7000

proxies:
  - name: ha-ui
    type: https
    localIp: "127.0.0.1"
    localPort: ${LOCAL_PORT}
    customDomains:
      - "${INSTANCE_ID}.ui.ha-tools.com"
    hostHeaderRewrite: "${INSTANCE_ID}.ui.ha-tools.com"
EOF

echo "-------- Generierte frpc.yaml --------"
cat "$CONFIG_PATH"
echo "--------------------------------------"

# 3) frpc starten
exec frpc -c "$CONFIG_PATH"
