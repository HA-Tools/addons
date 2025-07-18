#!/usr/bin/env bash
set -euo pipefail

# 1) Kandidaten‑Liste definieren (füge Ports hinzu, die du prüfen willst)
CANDIDATE_PORTS=(8123 443 80 8080 8243)
DEFAULT_PORT=8123
LOCAL_PORT=$DEFAULT_PORT

echo "Versuche, Home Assistant‑Port via curl zu entdecken…"

for p in "${CANDIDATE_PORTS[@]}"; do
  # Wähle Protokoll: Port 443 per HTTPS, der Rest per HTTP
  if [ "$p" -eq 443 ]; then
    proto="https"
  else
    proto="http"
  fi

  # HEAD‑Request mit kurzer Timeout‑Zeit
  status=$(curl -sI --connect-timeout 1 "$proto://localhost:$p" \
           | head -n1 \
           | awk '{print $2}')
  # Akzeptiere 200, 401 (Token-Required), 405 (Method Not Allowed)
  if [[ "$status" =~ ^(200|401|405)$ ]]; then
    LOCAL_PORT=$p
    echo "→ Home Assistant gefunden auf Port $p (HTTP-Status $status)"
    break
  fi
done

echo "Gefundener HA‑Port: $LOCAL_PORT (Fallback: $DEFAULT_PORT)"

# 2) Optionen aus JSON holen
OPTIONS=/data/options.json
SERVER_ADDR=$(jq -r '.server_addr' "$OPTIONS")
SERVER_PORT=$(jq -r '.server_port' "$OPTIONS")
TOKEN=$(jq -r '.token'       "$OPTIONS")
SUBDOMAIN=$(jq -r '.subdomain' "$OPTIONS")

echo "Starte FRPC mit:"
echo "  Server:    $SERVER_ADDR:$SERVER_PORT"
echo "  Token:     $TOKEN"
echo "  Subdomain: $SUBDOMAIN"

# 3) frpc.yaml generieren
cat > /data/frpc.yaml <<EOF
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
cat /data/frpc.yaml
echo "---------------------------"

# 4) FRPC starten
exec frpc -c /data/frpc.yaml
