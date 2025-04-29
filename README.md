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
   VPN_HOST=host.example.com
   VPN_USER=username
   VPN_PASS=password
   VPN_GROUP=group
   SHARED_IPS=192.168.0.0/24
   ```

### Environment Variables

- `VPN_HOST`: The VPN server hostname or IP address.
- `VPN_USER`: Your VPN username.
- `VPN_PASS`: Your VPN password.
- `VPN_GROUP`: The VPN group or profile to connect to.
- `SHARED_IPS`: Comma-separated list of private network IPs to access through the VPN.

## Usage

1. Build and start the container:
   ```bash
   docker compose up -d
   ```

2. Check the connection status:
   ```bash
   docker compose logs
   ```

3. To stop the VPN:
   ```bash
   docker compose down
   ```

## Accessing VPN Resources

Once the container is running, you need to configure your host system to access the shared IPs:

Configure routes on your host system (requires sudo permissions):

```bash
chmod +x setup-shared-ip.sh
```

```bash
./setup-shared-ip.sh
```

## Additional Notes

- Ensure that `setup-shared-ip.sh` is executed to configure NAT for shared IPs on your local machine.
- If this project is hosted on GitHub, your profile picture and name may appear in the repository's contributors section.
