# UT2 · Actividad en el aula 4 · Juego de rol: la transferencia de zona (guía del profesor)

> **Ruta:** `recursos/ut2-dns/actividades/rol-transferencia-zona.md`
> Guía y solución de la «Actividad en el aula 4» de `docs/ut2-dns/teoria.md` (apartado 6). No se publica en GitHub Pages.
> **Duración:** 15–20 min · **Sin ordenador** · **Criterios:** RA2.c (funcionalidad de los sistemas jerárquicos) y base de RA2.g (transferencias de zona).

## Objetivo

Que el alumnado vea con sus propios ojos:

- Por qué el secundario compara el **serial** antes de copiar la zona.
- Qué aportan **NOTIFY** y **refresh**, y por qué hay un rato en el que primario y secundario dan respuestas distintas.
- Qué pasa si se **olvida subir el serial**.
- Qué hacen **retry** y **expire** cuando el primario cae.
- Por qué el primario solo entrega la zona a servidores **autorizados**.

## Materiales

Para cada servidor (`ns1`, `ns2`, `ns3`), una tarjeta SOA y una tarjeta por registro. Para el primario, además, la lista de autorizados. Se pueden escribir a mano en folios partidos en cuatro.

```text
┌──────────────────────────────┐   ┌──────────────────────────────┐
│ SOA · zona smr2ser.test      │   │ www.smr2ser.test             │
│ Serial: 2026101501           │   │ A   192.168.10.100           │
│ Refresh: 2 rondas            │   └──────────────────────────────┘
│ Retry:   1 ronda             │   ┌──────────────────────────────┐
│ Expire:  4 rondas            │   │ mail.smr2ser.test            │
│ Último contacto: ronda __    │   │ A   192.168.10.100           │
└──────────────────────────────┘   └──────────────────────────────┘

┌──────────────────────────────┐   (Solo el primario)
│ ns1 · Autorizados AXFR:      │
│   ns2, ns3                   │
│ Avisar con NOTIFY a: ns2     │   ← el NOTIFY a ns3 «se pierde» (es UDP)
└──────────────────────────────┘
```

Tarjetas en blanco para los cambios del administrador: `www A 192.168.10.120` y `ftp A 192.168.10.130`.

En la pizarra, una tabla para seguir el juego:

| Ronda | Serial ns1 | Serial ns2 | Serial ns3 | ¿Qué responde cada uno a la pregunta del cliente? |
|---|---|---|---|---|

## Guion por rondas

| Ronda | Qué hace el profesor (administrador) / el reloj | Qué debe pasar | Lo que se ve |
|---|---|---|---|
| **0** | Reparto de tarjetas. Todos con serial `…01` | — | Los tres servidores responden `www → .100` |
| **1** | Cambia `www` a `.120` en ns1 y sube el serial a `…02`. ns1 envía **NOTIFY** solo a ns2 | ns2 pide el SOA → `02 > 01` → pide la zona (AXFR) y copia las tarjetas. ns3 no se entera | Un cliente pregunta a ns3 por `www` → **`.100` (respuesta antigua)** |
| **2** | El reloj anuncia el **refresh** (2 rondas) | ns2 y ns3 piden el SOA. ns3: `02 > 01` → copia la zona. ns2: `02 = 02` → no hace nada | Todos responden `.120`. Sin NOTIFY, el cambio tarda hasta un refresh en llegar |
| **3** | Añade `ftp A .130` en ns1, pero **no sube el serial** | Nadie se entera | Cliente pregunta `ftp` a ns1 → `.130`; a ns2 o ns3 → **«no existe»** (NXDOMAIN) |
| **4** | El reloj anuncia el refresh | ns2 y ns3 piden el SOA: `02 = 02` → **no copian** | `ftp` sigue sin existir en los secundarios. Al final de la ronda, el profesor «se da cuenta», sube a `…03` y envía NOTIFY a todos → todos copian. Anotar **último contacto = 4** |
| **5** | El primario **se cae** (el alumno se sienta y no contesta) | Los secundarios siguen respondiendo con su copia | Los clientes no notan nada: **tolerancia a fallos** |
| **6** | Refresh | ns2 y ns3 piden el SOA → sin respuesta → reintentarán cada ronda (**retry**) | Siguen respondiendo bien |
| **7** | — | Retry → sin respuesta | Siguen respondiendo bien |
| **8** | — | Retry → sin respuesta. Han pasado 4 rondas desde el último contacto: **expire** | A partir de ahora **dejan de responder** por la zona |
| **9** | Los clientes preguntan a ns2 y ns3 | — | **SERVFAIL**: «el servidor no puede responder». Sin primario durante demasiado tiempo, la zona deja de funcionar |
| **10** | El primario vuelve. Un alumno «intruso» (un cliente) le pide la zona completa (AXFR) | ns1 mira su lista: el intruso no está → **rechaza** la transferencia. ns2 y ns3 piden el SOA, ven `03 = 03`, y vuelven a responder | Seguridad: limitar las transferencias a los secundarios |

> Para no alargarlo, las rondas 6–8 se pueden hacer seguidas, con el reloj contando en voz alta.

## Preguntas de cierre (con respuesta)

1. **¿Por qué en la ronda 1 un cliente recibió `www → .100`?** Porque ns3 no recibió el NOTIFY y todavía no le tocaba el refresh: durante ese rato tenía una copia antigua. En Internet esto es normal y se reduce con NOTIFY y con un refresh corto.
2. **¿Qué pasó con `ftp` en las rondas 3 y 4?** Los secundarios comparan solo el serial. Como no cambió, no copiaron la zona y `ftp` no existía para ellos. **Regla: cada cambio en el primario, serial + 1.**
3. **¿Para qué sirve tener secundarios?** Ronda 5: el primario cayó y los clientes siguieron recibiendo respuestas (tolerancia a fallos). Además, reparten la carga.
4. **¿Por qué el secundario deja de responder tras el expire, si todavía tiene la copia?** Porque ya no puede garantizar que los datos sean correctos. Prefiere no responder antes que dar datos que podrían estar muy desactualizados.
5. **¿Qué ganaría el intruso con la zona completa?** El listado de todos los equipos de la red con sus IP: un mapa perfecto para atacarla. Por eso se limita con «Solo a los servidores de la pestaña Servidores de nombres» (Windows) o `allow-transfer` (BIND).
6. **¿Qué protocolo y puerto usa la transferencia?** TCP 53. Las consultas normales y el NOTIFY van por UDP 53; por eso un NOTIFY se puede «perder».

## Relación con la práctica

En la práctica con dos servidores se reproduce lo mismo:

- Windows Server: *Propiedades de la zona → Transferencias de zona* y botón **Notificar**; en el SOA, botón **Incremento** del número de serie.
- BIND: `allow-transfer` y `also-notify` en `named.conf.local`; en el fichero de zona, subir el serial a mano y `rndc reload`; en el secundario, `journalctl -u named` muestra la transferencia.