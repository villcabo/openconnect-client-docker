#!/bin/bash
set -e

VPN_INTERFACE="tun0"           # VPN interface (change if necessary)

# -----------------------------------------------------------------------------------
# Launch OpenVPN
if [ ! -z "$VPN_GROUP" ]; then
    AUTH_GROUP_ARG="--authgroup=$VPN_GROUP"
else
    AUTH_GROUP_ARG=""
fi

echo "Configuring OpenVPN..."
echo "$VPN_PASS" | openconnect --background \
    --user="$VPN_USER" \
    --passwd-on-stdin \
    $AUTH_GROUP_ARG \
    --no-dtls \
    "$VPN_HOST"

COUNT=0
while [ $COUNT -lt 30 ]; do
    if ip link show | grep -q $VPN_INTERFACE; then
        echo "Interface $VPN_INTERFACE detected!"
        break
    fi
    echo "Waiting for interface $VPN_INTERFACE... ($COUNT/30)"
    sleep 1
    COUNT=$((COUNT + 1))
done

if ! ip link show | grep -q $VPN_INTERFACE; then
    echo "Error: Could not establish the tun0 interface after 30 seconds"
    echo "Displaying OpenConnect logs:"
    cat /var/log/openconnect.log 2>/dev/null || echo "Log file not found"
    exit 1
fi
echo "OpenVPN connection established."

# -----------------------------------------------------------------------------------
# Function to configure the container (execute INSIDE the container)
echo ""
echo "Configuring the container as a bridge..."

# Configure NAT for the VPN
iptables -t nat -A POSTROUTING -o $VPN_INTERFACE -j MASQUERADE
iptables -A FORWARD -i eth0 -o $VPN_INTERFACE -j ACCEPT
iptables -A FORWARD -i $VPN_INTERFACE -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Container configured. Rules applied:"
iptables -t nat -L POSTROUTING -n -v

# -----------------------------------------------------------------------------------
# Keep the container running
echo ""
echo "VPN connected and configured. Keeping the container active"
tail -f /dev/null
