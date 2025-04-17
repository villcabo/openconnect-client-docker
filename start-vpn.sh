#!/bin/bash
set -e

# Verificar variables de entorno requeridas
if [ -z "$VPN_HOST" ]; then
    echo "Error: VPN_HOST no está definido"
    exit 1
fi

if [ -z "$VPN_USER" ]; then
    echo "Error: VPN_USER no está definido"
    exit 1
fi

if [ -z "$VPN_PASS" ]; then
    echo "Error: VPN_PASS no está definido"
    exit 1
fi

# Definir grupo de autenticación (opcional)
VPN_GROUP=${VPN_GROUP:-"rwv_sopvulcan"}

# Definir IPs a compartir (opcional)
SHARED_IPS=${SHARED_IPS:-"192.168.226.120"}

echo "Iniciando conexión VPN a $VPN_HOST..."

# Guardar la IP del contenedor para configurar SNAT después
CONTAINER_IP=$(hostname -i)
echo "IP del contenedor: $CONTAINER_IP"

# Configurar IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "IP forwarding habilitado"

# Iniciar OpenConnect en modo background
echo "$VPN_PASS" | openconnect --background \
    --user="$VPN_USER" \
    --passwd-on-stdin \
    --authgroup="$VPN_GROUP" \
    --no-dtls \
    "$VPN_HOST"

echo "Conexión VPN establecida. Configurando rutas..."

# Esperar a que se establezca la interfaz tun0
COUNT=0
while [ $COUNT -lt 30 ]; do
    if ip link show | grep -q tun0; then
        break
    fi
    sleep 1
    COUNT=$((COUNT+1))
done

if ! ip link show | grep -q tun0; then
    echo "Error: No se pudo establecer la interfaz tun0"
    exit 1
fi

# Configurar reglas para compartir las IPs específicas
echo "Configurando reglas de iptables para compartir IPs..."

# Obtener la IP de la puerta de enlace del host
HOST_GATEWAY=$(ip route | grep default | awk '{print $3}')
echo "Gateway del host: $HOST_GATEWAY"

# Configurar proxy ARP para las IPs compartidas
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "Configurando proxy ARP para $IP"
    
    # Agregar ruta para la IP específica a través de la VPN
    ip route add $IP/32 dev tun0
    
    # Configurar DNAT para redirigir conexiones a esa IP
    iptables -t nat -A PREROUTING -d $IP -j DNAT --to-destination $IP
    
    # Permitir tráfico de reenvío hacia la VPN
    iptables -A FORWARD -d $IP -j ACCEPT
    iptables -A FORWARD -s $IP -j ACCEPT
    
    # Configurar SNAT para el tráfico de retorno
    iptables -t nat -A POSTROUTING -s $IP -j SNAT --to-source $CONTAINER_IP
    
    echo "Configuración para $IP completada"
done

# Informar al usuario cómo acceder
echo "====================================================="
echo "Configuración completada. Para acceder a las IPs VPN:"
echo ""
echo "1. Agrega las siguientes entradas a tu archivo /etc/hosts:"
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "   $CONTAINER_IP    $IP    # Acceso VPN"
done
echo ""
echo "2. O configura una ruta en tu PC:"
for IP in $(echo $SHARED_IPS | tr ',' ' '); do
    echo "   sudo ip route add $IP/32 via $CONTAINER_IP"
done
echo "====================================================="

# Mantener el contenedor en ejecución
echo "VPN conectada y configurada. Manteniendo el contenedor activo..."
tail -f /dev/null
