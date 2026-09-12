---
title: UT1.2 - Teoría del servicio DHCP
---

# UT1.2: Instalación y configuración del servicio DHCP

**RA1:** Instala servicios de configuración dinámica, describiendo sus características y aplicaciones.

**Criterios de evaluación:**

| # | Criterio |
|---|---|
| a) | Se ha reconocido el funcionamiento de los mecanismos automatizados de configuración de los parámetros de red. |
| b) | Se han identificado las ventajas que proporcionan. |
| c) | Se han ilustrado los procedimientos y pautas que intervienen en una solicitud de configuración de los parámetros de red. |
| d) | Se ha instalado un servicio de configuración dinámica de los parámetros de red. |
| e) | Se ha preparado el servicio para asignar la configuración básica a los sistemas de una red local. |
| f) | Se han realizado asignaciones dinámicas y estáticas. |
| g) | Se han integrado en el servicio opciones adicionales de configuración. |
| h) | Se ha verificado la correcta asignación de los parámetros. |

> Esta página cubre los criterios **a, b y c** (fundamento teórico). Los criterios **d a h** (instalación, configuración y verificación) se trabajan en las prácticas.

## 1. Introducción (CE-a)

El protocolo de configuración dinámica de host (**DHCP**, *Dynamic Host Configuration Protocol*) es un estándar TCP/IP diseñado para simplificar la administración de la configuración IP de los equipos de una red.

### Ubicación de DHCP en la arquitectura TCP/IP

| Arquitectura TCP/IP | Modelo OSI | Protocolo | Unidad de transmisión |
|---|---|---|---|
| Aplicación | Aplicación / Presentación / Sesión | **DHCP** | Unidad de datos |
| Transporte | Transporte | UDP | Segmentos (puertos UDP 67 servidor / 68 cliente) |
| Internet | Red | IP | Paquetes (IPs de origen y destino) |
| Interfaz de red | Enlace | Ethernet | Tramas (MACs de origen y destino) |
| Interfaz de red | Físico | — | Bits |

### ¿Por qué es necesario?

Cada equipo de una red TCP/IP necesita un **nombre** y una **dirección IP únicos**. La dirección IP, junto con su máscara de subred, identifica tanto al equipo como a la subred a la que pertenece. Si un equipo cambia de red, hay que reasignarle su identificación. DHCP reduce la complejidad y la cantidad de trabajo que el administrador tendría que realizar para reconfigurar manualmente los equipos cada vez que esto ocurre.

## 2. Configuración manual vs. automática (CE-b)

### Inconvenientes de la configuración manual

- La configuración de red (IP, máscara, DNS...) se define a mano en cada equipo, lo que aumenta las tareas del administrador.
- Existe riesgo de introducir una configuración incorrecta que provoque problemas de comunicación.
- Si un equipo cambia de ubicación y se conecta a una subred diferente, hay que modificar manualmente su configuración (problema habitual en redes inalámbricas).
- Si la red crece o se reestructura, hay que modificar la configuración de todos los equipos, uno a uno.

### Ventajas de la configuración automática (DHCP)

- El servidor suministra automáticamente la configuración necesaria, reduciendo el trabajo del administrador.
- Los equipos nuevos se pueden conectar a la red sin intervención manual.
- Se garantiza que todos los equipos usan la información de configuración correcta, y permite cambiarla de forma centralizada.
- Facilita reestructurar la red o añadir/modificar servicios.
- Los equipos pueden cambiar de ubicación y reconfigurarse automáticamente.

> 💬 **Un mito habitual:** se suele desconfiar de DHCP por un supuesto exceso de tráfico de difusión (broadcast). En la práctica, en la mayoría de los casos ese tráfico se limita a un único paquete de difusión enviado por el cliente para descubrir el servidor DHCP — no un flujo constante de broadcasts.

## 3. Componentes del protocolo DHCP (CE-a, CE-c)

DHCP está basado en el modelo **cliente/servidor**, con los siguientes componentes:

| Componente | Función |
|---|---|
| **Servidor DHCP** | Asigna la configuración de red a los clientes. |
| **Clientes DHCP** | Realizan peticiones al servidor y configuran sus parámetros TCP/IP con las opciones recibidas. |
| **Protocolo DHCP** | Conjunto de normas y reglas mediante las que "dialogan" clientes y servidores. |
| **Agentes de retransmisión DHCP** | Escuchan peticiones de clientes DHCP y las retransmiten a servidores DHCP ubicados en otras redes/subredes. Permiten centralizar la configuración del servicio en múltiples redes sin necesidad de un servidor DHCP por cada subred. |

## 4. Procedimiento de una solicitud: proceso DORA (CE-c)

DHCP funciona mediante **broadcast** en 4 fases, conocidas como **DORA**:

1. **Discover** — El cliente, sin IP todavía, envía un broadcast `DHCPDISCOVER` buscando servidores DHCP en la red.
2. **Offer** — Cada servidor DHCP que recibe la petición responde con un `DHCPOFFER`, ofreciendo una IP disponible.
3. **Request** — El cliente elige una oferta y envía un `DHCPREQUEST` confirmando que la acepta.
4. **Acknowledge** — El servidor confirma la asignación con un `DHCPACK`, y el cliente ya puede usar esa configuración.

> 💡 Todo el proceso ocurre por broadcast porque el cliente **aún no tiene IP**. Por eso DHCP usa los puertos UDP 67 (servidor) y 68 (cliente).

### Tipos de mensajes DHCP

| Mensaje | Sentido | Significado |
|---|---|---|
| `DHCPDISCOVER` | Cliente → red (broadcast) | Detecta los servidores DHCP existentes. |
| `DHCPOFFER` | Servidor → cliente | Ofrece una configuración, en respuesta a un `DHCPDISCOVER`. |
| `DHCPREQUEST` | Cliente → servidor | Acepta la oferta, confirma la información antes del reinicio, o extiende el contrato de una IP ya asignada. |
| `DHCPACK` | Servidor → cliente | Envía al cliente la configuración definitivamente asignada. |
| `DHCPNAK` | Servidor → cliente | Indica que la dirección que el cliente tiene asignada es incorrecta o ha expirado. |
| `DHCPDECLINE` | Cliente → servidor | El cliente informa de que ha detectado un problema con la IP asignada (p. ej. ya está en uso). |
| `DHCPRELEASE` | Cliente → servidor | El cliente renuncia a la dirección otorgada y cancela el contrato (lease). |
| `DHCPINFORM` | Cliente → servidor | El cliente pide información adicional a la ya recibida en el `DHCPACK`. |

### Concepto de concesión (lease)

La IP no se asigna "para siempre": se **concede** durante un tiempo (lease time). Antes de que expire, el cliente intenta **renovarla** con el mismo servidor mediante un nuevo `DHCPREQUEST`.

## 5. Tipos de asignación

- **Dinámica:** el servidor asigna una IP libre de un rango (pool) definido, sin garantizar que sea siempre la misma.
- **Estática (reserva):** el servidor asigna siempre la misma IP a un equipo concreto, identificado por su dirección MAC.

## 6. Servidores DHCP en sistemas operativos propietarios

En entornos **Windows Server**, el servidor DHCP organiza los grupos de direcciones IP en **ámbitos** (*scopes*). Cuando un cliente entra en la red y solicita una dirección, se le autoriza a usar una IP de ese ámbito. Al crear un ámbito hay que evitar interferencias con IPs ya existentes (para no provocar conflictos) y no olvidar incluir DNS, máscara de red y puerta de enlace.

## 7. Servidores DHCP en sistemas operativos libres

En entornos Linux, la implementación de referencia históricamente ha sido **ISC DHCP** (el paquete `isc-dhcp-server`, que instalaremos en la práctica). Es la que vamos a usar en esta unidad, aunque conviene conocer que no es la única:

- **ISC DHCP (`dhcpd`):** implementación clásica, ampliamente usada en distribuciones Debian/Ubuntu. Se declara mediante fichero de texto (`/etc/dhcp/dhcpd.conf`).
- **Kea DHCP:** desarrollado también por ISC como sucesor de `dhcpd` (más moderno, con API REST y base de datos), va ganando terreno en despliegues nuevos.
- **dnsmasq:** solución ligera que combina DHCP y DNS en un solo servicio; muy habitual en routers domésticos y entornos embebidos.

A diferencia de Windows Server (donde el ámbito se crea con un asistente gráfico), en Linux la configuración se declara en un **fichero de texto plano**, lo que facilita automatizarla, versionarla (¡con Git, como este mismo repositorio!) y replicarla entre servidores.

### Equivalencia de conceptos: Windows Server vs. ISC DHCP (Linux)

| Concepto | Windows Server | ISC DHCP (Linux) |
|---|---|---|
| Grupo de IPs a repartir | Ámbito (*scope*), creado con el asistente | Bloque `subnet { }` en `/etc/dhcp/dhcpd.conf` |
| Rango de direcciones dinámicas | Rango del ámbito | Directiva `range` |
| Asignación fija a un equipo | Reserva | Bloque `host { hardware ethernet ...; fixed-address ...; }` |
| Opciones adicionales (DNS, gateway...) | Opciones de ámbito | Directivas `option ...` |
| Base de datos de concesiones activas | Consola DHCP (gráfica) | Fichero `/var/lib/dhcp/dhcpd.leases` |
| Arranque/parada del servicio | Servicios de Windows | `systemctl start/stop/restart isc-dhcp-server` |
| Registro de actividad | Visor de eventos | `journalctl -u isc-dhcp-server` |

> 🧩 **Ampliación (opcional):** también es posible desplegar un servidor DHCP dentro de un contenedor Docker, pero no de forma trivial. La red `bridge` por defecto de Docker aísla al contenedor mediante NAT, por lo que el tráfico de *broadcast* del proceso DORA no llega al resto de la LAN. Para que funcione de verdad haría falta crear una red de tipo **macvlan**, que le da al contenedor una interfaz con MAC/IP propias y visibilidad real en la red física. Es un buen ejercicio para quien quiera profundizar en redes de contenedores, pero no es el enfoque que seguiremos en esta unidad.

## 8. A continuación

Esta unidad incluye dos prácticas paso a paso, para comparar la misma tecnología en dos sistemas operativos distintos (CE-d a CE-h):

- 🪟 [Práctica: DHCP en Windows Server](practica-windows.md)
- 🐧 [Práctica: DHCP en Ubuntu Server (`isc-dhcp-server`)](practica-ubuntu.md)