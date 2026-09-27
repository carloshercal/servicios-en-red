# UT1 · DHCP — Ficheros de configuración de ejemplo

Ficheros completos y comentados de las prácticas UT1-P1 (Windows Server, `net01`) y UT1-P2 (Ubuntu Server, `net02`). Todas las MAC y credenciales son ficticias.

| Fichero | Se copia en | Práctica |
|---|---|---|
| [`dhcpd.conf`](dhcpd.conf) | `/etc/dhcp/dhcpd.conf` (Ubuntu Server) | UT1-P2 |
| [`isc-dhcp-server`](isc-dhcp-server) | `/etc/default/isc-dhcp-server` (Ubuntu Server) | UT1-P2 |
| [`netplan-servidor-ubuntu.yaml`](netplan-servidor-ubuntu.yaml) | `/etc/netplan/50-cloud-init.yaml` (Ubuntu Server) | UT1-P2 |
| [`interfaces-cliente-debian`](interfaces-cliente-debian) | `/etc/network/interfaces` (cliente Debian 12) | UT1-P1 y UT1-P2 |
| [`dhcp-windows-server.ps1`](dhcp-windows-server.ps1) | Se ejecuta por bloques en PowerShell (Administrador) | UT1-P1 |

Comprobar la sintaxis de `dhcpd.conf` antes de reiniciar el servicio:

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```
