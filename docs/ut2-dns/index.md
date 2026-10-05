---
title: "UT2 · Servicios de resolución de nombres (DNS)"
---

# UT2 · Instalación de servicios de resolución de nombres (DNS)

> **Módulo:** Servicios en Red · 2º CFGM Sistemas Microinformáticos y Redes · Curso 2026/2027
> **Duración:** 18 h · **Fechas:** 08/10/2026 – 29/10/2026
> [← Volver a la portada del módulo](../index.md)

## Resultado de aprendizaje

**RA2.** Instala servicios de resolución de nombres, describiendo sus características y aplicaciones.

| Criterio | Descripción | Dónde se trabaja |
|---|---|---|
| RA2.a | Se han identificado y descrito escenarios en los que surge la necesidad de un servicio de resolución de nombres. | Teoría |
| RA2.b | Se han clasificado los principales mecanismos de resolución de nombres. | Teoría |
| RA2.c | Se ha descrito la estructura, nomenclatura y funcionalidad de los sistemas de nombres jerárquicos. | Teoría |
| RA2.d | Se ha instalado un servicio jerárquico de resolución de nombres. | Prácticas Windows y Ubuntu |
| RA2.e | Se ha preparado el servicio para almacenar las respuestas procedentes de servidores de redes públicas y servirlas a los equipos de la red local. | Prácticas (caché y reenviadores) |
| RA2.f | Se han añadido registros de nombres correspondientes a una zona nueva, con opciones relativas a servidores de correo y alias. | Prácticas (registros A, MX, CNAME, PTR) |
| RA2.g | Se ha trabajado en grupo para realizar transferencias de zona entre dos o más servidores. | Prácticas (servidor secundario) |
| RA2.h | Se ha comprobado el funcionamiento correcto del servidor. | Prácticas (verificación) |

## Contenidos

1. 📖 [Teoría del servicio DNS](teoria.md) — mecanismos de resolución, espacio de nombres de dominio, consultas recursivas e iterativas, tipos de servidores, zonas y registros.
2. 🛠️ Prácticas paso a paso — instalación y configuración del servicio en dos sistemas operativos distintos:
   - 🪟 [Práctica: DNS en Windows Server](practica-windows.md)
   - 🐧 [Práctica: DNS en Ubuntu Server (`bind9`)](practica-ubuntu.md)

## Entorno de prácticas

Se mantiene el escenario de la UT1. Cambia el dominio: en esta UT usamos **`smr2ser.test`**, un dominio reservado para pruebas que no existe en Internet.

| Elemento | Práctica Windows (`net01`) | Práctica Ubuntu (`net02`) |
|---|---|---|
| Red interna | `192.168.10.0/24` | `172.16.2.0/24` |
| Servidor DNS primario | `WIN25-SER` · Windows Server 2025 · `192.168.10.100` | `ubuntuserver24` · Ubuntu Server 24.04 LTS · `172.16.2.1` |
| Servidor DNS secundario | Segundo Windows Server · `192.168.10.200` | Segundo Ubuntu Server · IP por concretar en la práctica |
| Router | Debian 12 · `192.168.10.254` | Debian 12 · `172.16.2.254` |
| Clientes | Windows 7 · Debian 12 (`192.168.10.150`) | Windows 7 · Debian 12 (`172.16.2.50`) |
| Reenviadores | DNS de Educacyl: `10.151.123.21` y `10.151.126.21` | Ídem |

> 🔒 Todo se monta en **redes internas de VirtualBox**. Ningún servidor DNS debe estar en modo «Adaptador puente».

## Recursos

- Diagramas de la UT: `recursos/ut2-dns/diagramas/`
- Ficheros de configuración de ejemplo: `recursos/ut2-dns/ficheros-config/`
- [Root Zone Database (IANA)](https://www.iana.org/domains/root/db) · [Parámetros DNS (IANA)](https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml) · [Documentación de BIND 9](https://bind9.readthedocs.io/)

> Las tareas, entregas y la evaluación están en **Microsoft Teams** (Trabajo de clase → UT2). Esta web es solo material de consulta.
