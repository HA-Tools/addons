FROM alpine:latest

RUN apk add --no-cache curl tar bash gettext

ENV FRP_VERSION=0.58.0

# FRPC herunterladen
RUN curl -L -o frp.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz \
    && tar -xzf frp.tar.gz \
    && mv frp_${FRP_VERSION}_linux_amd64/frpc /usr/local/bin/frpc \
    && rm -rf frp*

# Dateien kopieren
COPY run.sh /run.sh
COPY frpc.ini.j2 /frpc.ini.j2

RUN chmod +x /run.sh

CMD ["/run.sh"]
