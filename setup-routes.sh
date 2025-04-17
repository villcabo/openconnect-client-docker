#!/bin/bash
# Script para configurar las rutas al host desde la máquina local

# Obtener la IP del contenedor VPN
CONTAINER_ID=$(docker compose ps -q vpn)
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: El contenedor VPN no está en ejecución"
    exit 1
fi

CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)
if [ -z "$CONTAINER_IP" ]; then
    echo "Error: No se pudo obtener la IP del contenedor"
    exit 1
fi

echo "IP del contenedor VPN: $CONTAINER_IP"

# Cargar las IPs compartidas desde el archivo .env
if [ -f .env ]; then
    source .env
else
    echo "Advertencia: No se encontró el archivo .env, usando IP predeterminada 192.168.226.120"
    SHARED_IPS="192.168.226.120"
fi

# Configurar las rutas para cada IP compartida
echo "Configurando rutas para acceder a IPs de la VPN..."
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "Configurando ruta para $IP via $CONTAINER_IP"
    sudo ip route add $IP/32 via $CONTAINER_IP
done

echo "Rutas configuradas correctamente"
echo ""
echo "Para probar la conexión, intenta:"
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "  ping $IP"
done
echo ""
echo "Para acceder a servicios web, usa tu navegador para acceder a:"
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "  http://$IP"
done
