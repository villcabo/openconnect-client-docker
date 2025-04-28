#!/bin/bash
set -e

VPN_INTERFACE="tun0"           # Interfaz VPN (cambiar si es necesario)
    
# Colores para los logs
BOLD="\033[1m"
NORMAL="\033[0m"

# -----------------------------------------------------------------------------------

# Launch Openvpn
echo "${BOLD}➔ Configurando OpenVPN ⏳...${NORMAL}"
echo "$VPN_PASS" | openconnect --background \
    --user="$VPN_USER" \
    --passwd-on-stdin \
    $AUTH_GROUP_ARG \
    --no-dtls \
    "$VPN_HOST"

COUNT=0
while [ $COUNT -lt 30 ]; do
    if ip link show | grep -q $VPN_INTERFACE; then
        echo "${BOLD}➔ Interfaz $VPN_INTERFACE detectada! ✅${NORMAL}"
        break
    fi
    echo "${BOLD}➔ Esperando a la interfaz $VPN_INTERFACE... ($COUNT/30)${NORMAL}"
    sleep 1
    COUNT=$((COUNT + 1))
done

if ! ip link show | grep -q $VPN_INTERFACE; then
    echo "${BOLD}➔ Error: No se pudo establecer la interfaz tun0 después de 30 segundos ❌${NORMAL}"
    echo "Mostrando logs de OpenConnect:"
    cat /var/log/openconnect.log 2>/dev/null || echo "No se encontró el archivo de log"
    exit 1
fi
echo "${BOLD}➔ OpenVPN connection established. 🚀${NORMAL}"

# -----------------------------------------------------------------------------------
# Función para configurar el contenedor (ejecutar DENTRO del contenedor)
echo ""
echo "${BOLD}➔ Configurando el contenedor como puente ⏳...${NORMAL}"

# Configurar NAT para la VPN
iptables -t nat -A POSTROUTING -o $VPN_INTERFACE -j MASQUERADE
iptables -A FORWARD -i eth0 -o $VPN_INTERFACE -j ACCEPT
iptables -A FORWARD -i $VPN_INTERFACE -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "➔ Contenedor configurado. Reglas aplicadas ✅:"
iptables -t nat -L POSTROUTING -n -v

# -----------------------------------------------------------------------------------
# Mantener el contenedor en ejecución
echo ""
echo "${BOLD}➔ VPN conectada y configurada. Manteniendo el contenedor activo 🚀${NORMAL}"
tail -f /dev/null
