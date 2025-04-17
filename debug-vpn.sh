#!/bin/bash
# Script para depurar problemas con el contenedor VPN

# Verificar si el contenedor está en ejecución
CONTAINER_ID=$(docker compose ps -q vpn)
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: El contenedor VPN no está en ejecución"
    exit 1
fi

echo "===== Información del contenedor ====="
docker inspect $CONTAINER_ID

echo -e "\n===== Logs del contenedor ====="
docker logs $CONTAINER_ID

echo -e "\n===== Información de red del contenedor ====="
docker exec $CONTAINER_ID ip addr show
docker exec $CONTAINER_ID ip route

echo -e "\n===== Estado de iptables ====="
docker exec $CONTAINER_ID iptables -t nat -L -v
docker exec $CONTAINER_ID iptables -L -v

echo -e "\n===== Prueba de conexión desde dentro del contenedor ====="
echo "Probando conectividad dentro del contenedor:"
docker exec $CONTAINER_ID ping -c 3 8.8.8.8 || echo "No hay conectividad a Internet desde el contenedor"

# Obtener IPs compartidas
if [ -f .env ]; then
    source .env
else
    SHARED_IPS="192.168.226.120"
fi

echo -e "\n===== Prueba de conexión a IPs VPN ====="
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "Probando conectividad a $IP desde el contenedor:"
    docker exec $CONTAINER_ID ping -c 3 $IP || echo "No hay conectividad a $IP desde el contenedor"
done

echo -e "\n===== Verificar el proceso OpenConnect ====="
docker exec $CONTAINER_ID ps aux | grep openconnect

echo -e "\n===== Ingresar a una shell en el contenedor ====="
echo "Para ingresar al contenedor y depurar manualmente, ejecuta:"
echo "docker exec -it $CONTAINER_ID /bin/bash"