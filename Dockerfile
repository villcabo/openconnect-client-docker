FROM ubuntu:latest

# Evitar prompts durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar OpenConnect y herramientas necesarias
RUN apt-get update && \
    apt-get install -y \
    openconnect \
    iptables \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    dnsutils \
    procps \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para scripts
RUN mkdir -p /scripts

# Agregar script para iniciar la VPN
COPY start-vpn.sh /scripts/
RUN chmod +x /scripts/start-vpn.sh

# Punto de entrada del contenedor
CMD ["/scripts/start-vpn.sh"]
