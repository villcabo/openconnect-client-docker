# Docker VPN con OpenConnect

Este proyecto proporciona una configuración Docker para conectarse a una VPN mediante OpenConnect, manteniendo la conexión a internet local y permitiendo acceder a IPs específicas de la red privada desde el host.

## Archivos incluidos

- `Dockerfile`: Configura la imagen base con OpenConnect y herramientas necesarias
- `docker-compose.yml`: Define el servicio y la configuración de red
- `start-vpn.sh`: Script que gestiona la conexión a la VPN y el enrutamiento
- `.env.example`: Ejemplo de archivo de variables de entorno

## Configuración

1. Copia `.env.example` a `.env`:
   ```
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus credenciales:
   ```
   VPN_HOST=rtwork.bancounion.com.bo
   VPN_USER=tu_usuario
   VPN_PASS=tu_contraseña
   VPN_GROUP=rwv_sopvulcan
   SHARED_IPS=192.168.226.120
   ```

## Uso

1. Construye e inicia el contenedor:
   ```
   docker-compose up -d
   ```

2. Verifica el estado de la conexión:
   ```
   docker-compose logs
   ```

3. Configura las rutas en tu sistema host (requiere permisos sudo):
   ```
   chmod +x setup-routes.sh
   ./setup-routes.sh
   ```

4. Para detener la VPN:
   ```
   docker-compose down
   ```

## Acceso a recursos de la VPN

Una vez que el contenedor esté en funcionamiento, necesitarás configurar tu sistema host para acceder a las IPs compartidas:

### Opción 1: Configurar rutas en el host

Una vez que el contenedor esté funcionando, revisa los logs para ver la IP del contenedor:

```
docker-compose logs vpn
```

Luego, agrega una ruta en tu sistema host:

```
sudo ip route add 192.168.226.120/32 via [IP_DEL_CONTENEDOR]
```

### Opción 2: Modificar archivo hosts

Alternativamente, puedes agregar una entrada en tu archivo `/etc/hosts`:

```
[IP_DEL_CONTENEDOR]    192.168.226.120    # Acceso VPN
```

Una vez configurado, podrás acceder a `http://192.168.226.120` desde tu navegador local.

## Solución de problemas

Si tienes problemas con la conexión:

1. Verifica los logs del contenedor:
   ```
   docker-compose logs -f
   ```

2. Comprueba el estado de las rutas de red:
   ```
   docker exec vpn-container ip route
   ```

3. Prueba la conectividad desde dentro del contenedor:
   ```
   docker exec vpn-container ping 192.168.226.120
   ```
