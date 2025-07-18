FROM alpine:latest

RUN apk add --no-cache curl tar bash

ENV FRP_VERSION=0.58.0

# Download & entpacke FRPC
RUN curl -L -o frp.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz \
    && tar -xzf frp.tar.gz \
    && mv frp_${FRP_VERSION}_linux_amd64/frpc /usr/local/bin/frpc \
    && rm -rf frp*

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
