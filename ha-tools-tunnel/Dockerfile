FROM alpine:latest

RUN apk add --no-cache curl tar bash gettext

ENV FRP_VERSION=0.58.0

# Ermittle Architektur
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)   PLATFORM="amd64" ;; \
      aarch64)  PLATFORM="arm64" ;; \
      armv7l)   PLATFORM="arm" ;; \
      *)        echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -L -o frp.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${PLATFORM}.tar.gz && \
    tar -xzf frp.tar.gz && \
    mv frp_${FRP_VERSION}_linux_${PLATFORM}/frpc /usr/local/bin/frpc && \
    chmod +x /usr/local/bin/frpc && \
    rm -rf frp*

COPY run.sh /run.sh
COPY frpc.ini.j2 /frpc.ini.j2

RUN chmod +x /run.sh

CMD ["/run.sh"]
