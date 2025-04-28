# Docker VPN with OpenConnect

This project provides a Docker setup to connect to a VPN using OpenConnect, maintaining local internet access while allowing access to specific private network IPs from the host.

## Prerequisites

- Docker and Docker Compose installed on your system.
- Basic knowledge of networking and VPN configurations.
- Sudo/root access to configure routes on your host system.

## Included Files

- `Dockerfile`: Configures the base image with OpenConnect and necessary tools.
- `docker-compose.yml`: Defines the service and network configuration.
- `start-vpn.sh`: Script to manage the VPN connection and routing.
- `setup-shared-ip.sh`: Script to configure NAT for shared IPs on your local machine.
- `.env.example`: Example environment variables file.

## Configuration

1. Copy `.env.example` to `.env`:
   ```
   cp .env.example .env
   ```

2. Edit the `.env` file with your credentials and configuration:
   ```
   VPN_HOST=rtwork.bancounion.com.bo
   VPN_USER=your_username
   VPN_PASS=your_password
   VPN_GROUP=rwv_sopvulcan
   SHARED_IPS=192.168.226.0/24
   ```

### Environment Variables

- `VPN_HOST`: The VPN server hostname or IP address.
- `VPN_USER`: Your VPN username.
- `VPN_PASS`: Your VPN password.
- `VPN_GROUP`: The VPN group or profile to connect to.
- `SHARED_IPS`: Comma-separated list of private network IPs to access through the VPN.

## Usage

1. Build and start the container:
   ```
   docker compose up -d
   ```

2. Check the connection status:
   ```
   docker compose logs
   ```

3. Configure routes on your host system (requires sudo permissions):
   ```
   chmod +x setup-shared-ip.sh
   ./setup-shared-ip.sh
   ```

4. To stop the VPN:
   ```
   docker compose down
   ```

## Accessing VPN Resources

Once the container is running, you need to configure your host system to access the shared IPs:

### Option 1: Configure Routes on the Host

After the container is running, check the logs to find the container's IP address:

```
docker compose logs vpn
```

Then, add a route on your host system:

```
sudo ip route add 192.168.226.120/32 via [CONTAINER_IP]
```

### Option 2: Modify the Hosts File

Alternatively, you can add an entry to your `/etc/hosts` file:

```
[CONTAINER_IP]    192.168.226.120    # VPN Access
```

Once configured, you can access `http://192.168.226.120` from your local browser.

## Troubleshooting

If you encounter issues with the connection:

1. Check the container logs:
   ```
   docker compose logs -f
   ```

2. Verify the network routes:
   ```
   docker exec vpn-container ip route
   ```

3. Test connectivity from inside the container:
   ```
   docker exec vpn-container ping 192.168.226.120
   ```

## Additional Notes

- Ensure that `setup-shared-ip.sh` is executed to configure NAT for shared IPs on your local machine.
- If this project is hosted on GitHub, your profile picture and name may appear in the repository's contributors section.
