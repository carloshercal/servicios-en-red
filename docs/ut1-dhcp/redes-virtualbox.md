---
title: UT1.1b - Redes virtuales en VirtualBox
---

# Redes virtuales en VirtualBox

![VirtualBox](img/virtualbox-destacada.png)

Antes de montar el escenario de DHCP (router + servidor + clientes), conviene tener claro cómo funcionan los distintos tipos de adaptador de red que ofrece VirtualBox, porque de ello depende **qué máquinas se ven entre sí** y **quién tiene salida a Internet**.

## Tipos de adaptador de red en VirtualBox

| Tipo de adaptador | ¿Acceso a Internet? | ¿Las VM se ven entre sí? | ¿El host ve a la VM? | Uso típico |
|---|---|---|---|---|
| **NAT** | Sí (a través del host) | No (cada VM está aislada de las demás) | No directamente | Dar salida a Internet a una VM individual, sin exponerla a la red física. |
| **Red NAT (NAT Network)** | Sí | Sí, entre las VM de la misma Red NAT | No directamente | Varias VM que necesitan Internet **y** verse entre sí, sin tocar la red física. |
| **Adaptador puente (Bridged)** | Sí (la VM sale como un equipo más de tu red física) | Sí, con cualquier equipo de tu red física | Sí | Que la VM parezca un equipo más conectado directamente a tu router/red doméstica. |
| **Red interna (Internal Network)** | **No** | Sí, solo entre las VM que comparten el mismo nombre de red interna | **No** | Crear una red totalmente aislada y controlada, donde el único camino de salida sea el que vosotros configuréis (p. ej. a través de un router virtual). |
| **Solo anfitrión (Host-only)** | No (salvo que el propio host haga de NAT) | Sí, entre las VM de la misma red host-only | Sí, el host también forma parte de esa red | Que el host pueda administrar las VM directamente, sin salida a Internet. |
| **Controlador genérico** | Depende | Depende | Depende | Casos avanzados (VDE, túneles UDP...). No lo usaremos en el módulo. |

> 💡 La diferencia clave para nuestro escenario es: **Red interna** crea una red completamente aislada, invisible tanto para Internet como para el propio equipo físico (el host) — solo existe entre las VM que tú conectes a ella. Es justo lo que necesitamos para que el único camino de salida de `net01` y `net02` sea a través de nuestro router Debian, tal y como ocurre en una red real.

## Por qué usamos "Red interna" y no "Solo anfitrión" ni "Puente"

- Si usáramos **Adaptador puente**, cada VM aparecería directamente en tu red doméstica/del aula, con IPs de esa red — perderíamos el control sobre el direccionamiento (`192.168.10.0/24`, `172.16.2.0/24`) que queremos usar en las prácticas.
- Si usáramos **Solo anfitrión**, tu propio PC (el host) pasaría a formar parte de la red `net01`/`net02`, lo cual no refleja una red real (donde el "router" es una máquina más de la topología, no tu portátil).
- Con **Red interna**, `net01` y `net02` son redes que **solo existen dentro de VirtualBox**, completamente aisladas entre sí y del host. La única forma de que un equipo de `net01` llegue a Internet (o a `net02`) es pasando por el router Debian, que sí tiene salida real mediante su adaptador NAT. Esto obliga al alumnado a entender y configurar el enrutamiento, en lugar de que "funcione solo".

## Configuración de red del router Debian 12

El router es la única máquina de esta unidad con **tres adaptadores de red**:

| Adaptador | Tipo en VirtualBox | Red | Función |
|---|---|---|---|
| Adaptador 1 | NAT | — | Salida a Internet (actualizaciones del propio Debian, resolución DNS externa, etc.) |
| Adaptador 2 | Red interna | `net01` (`192.168.10.0/24`) | Puerta de enlace de la red de la práctica de Windows Server (`192.168.10.254`) |
| Adaptador 3 | Red interna | `net02` (`172.16.2.0/24`) | Puerta de enlace de la red de la práctica de Ubuntu Server (`172.16.2.254`) |

En Debian, cada adaptador se corresponde con una interfaz de red (comprobable con `ip a`), típicamente en el mismo orden en que se añadieron en VirtualBox:

| Adaptador VirtualBox | Interfaz habitual en Debian |
|---|---|
| Adaptador 1 (NAT) | `enp0s3` |
| Adaptador 2 (Red interna `net01`) | `enp0s8` |
| Adaptador 3 (Red interna `net02`) | `enp0s9` |

> ⚠️ Los nombres exactos (`enp0s3`, `enp0s8`...) pueden variar según la versión de VirtualBox y el chipset de red virtual elegido. Compruébalos siempre con `ip a` antes de configurar nada.

Para que los equipos de `net01` y `net02` tengan salida a Internet a través del router, este necesita:

1. **Reenvío de paquetes activado** (`net.ipv4.ip_forward=1`).
2. **NAT/enmascaramiento** de `net01` y `net02` hacia el adaptador NAT (regla `iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE`, o el equivalente que usemos con `nftables`).

> 📌 El montaje detallado y razonado de este router (reglas de firewall, `ip_forward`, persistencia de la configuración) se trabaja a fondo en la **UT7 (interconexión de redes privadas y públicas)**. Aquí solo necesitamos que esté operativo como puerta de enlace para poder centrarnos en el servicio DHCP.

## A continuación

👉 Con la red ya montada, pasa a la [teoría del servicio DHCP](teoria.md).
