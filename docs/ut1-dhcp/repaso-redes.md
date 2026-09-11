---
title: UT1.1 - Repaso de conceptos de redes
---

# UT1.1: Repaso de conceptos de redes

**RA1:** Instala servicios de configuración dinámica, describiendo sus características y aplicaciones.

**Criterio de evaluación:**
> a) Se ha reconocido el funcionamiento de los mecanismos automatizados de configuración de los parámetros de red.

Antes de instalar el servicio DHCP, es necesario repasar una serie de conceptos de redes vistos ya en el módulo de Redes Locales de 1º.

## 1. Conceptos fundamentales de redes

- **Red:** conjunto de dispositivos interconectados que comparten recursos y se comunican entre sí.
- **Nodo:** cualquier dispositivo conectado a una red (ordenador, impresora, router, etc.).
- **Host:** nodo capaz de enviar y recibir datos en una red (normalmente un ordenador o un servidor).

### Modelos de comunicación entre aplicaciones

Para que las aplicaciones se comuniquen a través de una red se emplean fundamentalmente tres modelos:

| Modelo | Descripción |
|---|---|
| **Cliente/Servidor** | Se distingue un proceso cliente (solicita servicios) y un proceso servidor (presta servicios). Es el más extendido y utilizado. |
| **Entre pares (P2P)** | No existe un elemento que centralice la comunicación; todos los nodos son responsables por igual. |
| **Híbrido** | Combinación de los dos anteriores: el servidor no presta el servicio en sí, sino que pone en contacto a los clientes para que se comuniquen entre ellos. |

En el modelo cliente/servidor:

- **Cliente:** proceso que habitualmente inicia la comunicación, envía una petición al servidor y queda a la espera de respuesta. Es el elemento **activo**.
- **Servidor:** proceso que permanece a la espera, escuchando las posibles conexiones de los clientes. Es el elemento **pasivo**.

### Tipos de redes según su alcance

| Tipo | Significado | Ejemplo |
|---|---|---|
| **LAN** (Local Area Network) | Red local, de ámbito reducido | Una oficina, un aula |
| **WAN** (Wide Area Network) | Red de gran alcance que conecta múltiples LAN | Internet |
| **WLAN** (Wireless LAN) | Red LAN que utiliza tecnología inalámbrica | Wi-Fi |

### Medios de transmisión

- Cableado de cobre (par trenzado)
- Fibra óptica
- Radiofrecuencia (Wi-Fi)
- Otros (medios guiados vs. no guiados)

### Topologías de red

- **Estrella:** todos los nodos conectados a un switch central.
- **Bus:** los nodos comparten una única línea principal.
- **Anillo:** conexión circular entre nodos.
- **Malla:** cada nodo conectado con varios otros.

## 2. Direccionamiento IP

El protocolo IP proporciona conectividad extremo a extremo en la comunicación: es capaz de direccionar de forma única todos los dispositivos conectados a la red.

> ⚠️ **Importante:** una dirección IP NO identifica a un ordenador en la red, sino que identifica a **una interfaz de red** de un ordenador en la red. Un mismo equipo con varias tarjetas de red tendrá varias direcciones IP.

### Estructura de una dirección IPv4

Una dirección IPv4 consta de 4 bytes (32 bits) que determinan:

- La **clase** (A, B, C, D o E).
- El identificador de red (**NetID**).
- El identificador de host (**HostID**).

La cantidad de bits dedicados a NetID y a HostID depende de la clase de la dirección.

### Direcciones reservadas

Direcciones que **no puede tomar un host**, porque identifican a la propia red o sirven para difusión:

| Dirección | Significado | Ejemplo (red 192.168.1.0/24) |
|---|---|---|
| **Dirección de red** | Identifica toda la red | 192.168.1.0 |
| **Dirección de difusión (broadcast)** | Envía mensajes a todos los hosts de la red | 192.168.1.255 |

El rango válido de direcciones para los hosts está comprendido entre esas dos direcciones.

### Direcciones especiales

Direcciones que sí puede tomar un host, pero que tienen un significado específico:

| Nombre | Rango | Significado |
|---|---|---|
| Mi propio host | 0.0.0.0 | Dirección de un equipo antes de recibir configuración. También se usa en routers como ruta por defecto cuando no se conoce otra mejor. |
| Bucle local (loopback) | 127.0.0.1 – 127.255.255.255 | Dirección local de prueba: los paquetes no salen al cable, se tratan como paquetes de entrada al propio equipo. |
| Enlace local | 169.254.0.0 – 169.254.255.255 | Dirección que el sistema operativo puede autoasignarse cuando falla la configuración dinámica (falla el DHCP). |

### Direcciones privadas

No son enrutables directamente en Internet; se usan en redes locales:

| Clase | Red | Nº de redes | Rango de direcciones |
|---|---|---|---|
| A | 10.0.0.0 | 1 | 10.0.0.0 – 10.255.255.255 |
| B | 172.16.0.0 – 172.31.0.0 | 16 | 172.16.0.0 – 172.31.255.255 |
| C | 192.168.0.0 – 192.168.255.0 | 256 | 192.168.0.0 – 192.168.255.255 |

## 3. Protocolos básicos

El modelo **OSI** ofrece una referencia teórica muy bien diseñada, pero nunca se llegó a implementar como tal en un modelo comercial. La arquitectura **TCP/IP** ya estaba en pleno funcionamiento cuando surgió OSI, y es la que se sigue utilizando hoy en día; el modelo OSI se usa solo como referencia para entender las distintas capas.

La arquitectura TCP/IP proporciona una estructura y una serie de normas de funcionamiento para interconectar sistemas. Cada capa realiza una labor concreta, y la integración modular y jerárquica de todas ellas hace posible la comunicación. En cada capa existen protocolos que ofrecen normas estrictas para el diálogo entre sistemas.

### Protocolos principales

- **TCP/IP:** conjunto de protocolos fundamentales de Internet.
  - **TCP:** proporciona conexión fiable (orientado a conexión).
  - **IP:** se encarga del direccionamiento.
- **UDP:** protocolo sin conexión, más rápido pero sin verificación de entrega. Usado en streaming, VoIP.
- **ICMP:** protocolo para mensajes de error y diagnóstico (lo utiliza, por ejemplo, el comando `ping`).

### Puertos y servicios estándar

| Servicio | Puerto |
|---|---|
| HTTP | 80 |
| HTTPS | 443 |
| FTP | 21 |
| SSH | 22 |
| DNS | 53 |
| SMTP | 25 |
| DHCP | 67/68 |

## 4. Herramientas básicas de diagnóstico

| Herramienta | Sistema | Para qué sirve |
|---|---|---|
| `ping` | Windows / Linux | Comprueba la conectividad entre equipos mediante ICMP (envía un *echo request* y espera un *echo reply*). |
| `ipconfig` | Windows | Muestra la configuración IP del equipo. |
| `ifconfig` / `ip a` | Linux | Muestra la configuración IP del equipo. |
| `tracert` | Windows | Muestra la ruta (saltos) que siguen los paquetes hasta un destino. |
| `traceroute` | Linux | Equivalente a `tracert` en Linux. |

---

👉 Continúa con la [teoría del servicio DHCP](teoria.md).