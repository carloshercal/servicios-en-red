# UT2 · Actividad en el aula 5 · Arregla el fichero de zona (solución)

> **Ruta:** `recursos/ut2-dns/actividades/arregla-fichero-zona.md`
> Solución de la «Actividad en el aula 5» de `docs/ut2-dns/teoria.md` (apartado 7). No se publica en GitHub Pages.
> **Duración:** 20 min · **En papel, por parejas** · **Criterios:** RA2.c y base de RA2.f (registros de una zona nueva con correo y alias).
> El escenario (`jamones-guijuelo.test`, `10.10.20.0/24`) es distinto al de las prácticas a propósito.

## Los 10 errores

| Nº | Línea | Error | Regla que incumple | Corrección |
|---|---|---|---|---|
| 1 | SOA | `ns1.jamones-guijuelo.test` **sin punto final** | Un FQDN termina en punto; si no, se le añade el dominio → `ns1.jamones-guijuelo.test.jamones-guijuelo.test.` | `ns1.jamones-guijuelo.test.` |
| 2 | SOA | `admin@jamones-guijuelo.test.` | En el SOA, la @ del correo se escribe como **punto** | `admin.jamones-guijuelo.test.` |
| 3 | SOA | Serial `2026101501`, el mismo que ayer | Cada cambio exige **subir el serial**; si no, los secundarios no copian la zona | `2026101502` |
| 4 | `@ CNAME www…` | **CNAME en el `@`** de la zona | Un nombre con CNAME no puede tener otros registros, y en `@` ya están SOA, NS y MX | `@ IN A 10.10.20.30` |
| 5 | NS | `ns2.jamones-guijuelo.test.` **no tiene registro A** | Un NS dentro de la propia zona necesita su registro A | `ns2 IN A 10.10.20.11` |
| 6 | `www A` | `10.10.20.300` | IP inválida: cada octeto va de 0 a 255 (además, la de `www` es `.30`) | `www IN A 10.10.20.30` |
| 7 | MX | Apunta a `correo`, que es un **CNAME** | MX y NS deben apuntar a un nombre con registro **A**, nunca a un alias | `correo IN A 10.10.20.10` (o `MX 10 servidor.jamones-guijuelo.test.`) |
| 8 | `intranet` | `CNAME 10.10.20.10` | Un CNAME apunta a un **nombre**, no a una IP | `intranet IN CNAME servidor.jamones-guijuelo.test.` |
| 9 | `ftp` | `ftp` tiene **CNAME y A** a la vez | Un nombre con CNAME no puede tener ningún otro registro | Dejar solo uno: `ftp IN CNAME copia.jamones-guijuelo.test.` |
| 10 | `25 PTR` | **PTR en una zona directa** | Los PTR van en la zona **inversa** (`20.10.10.in-addr.arpa`); aquí `25` sería `25.jamones-guijuelo.test.` | Quitarlo de aquí y ponerlo en la zona inversa |

> Errores que suelen «encontrar» y **no** lo son: que `ns1` y `servidor` tengan la misma IP (es correcto: dos registros A pueden apuntar a la misma IP) o que falte el TTL en cada línea (se usa el `$TTL` del principio).

## Zona directa corregida

```text
$TTL 86400                                      ; TTL por defecto: 1 día
@         IN  SOA    ns1.jamones-guijuelo.test. admin.jamones-guijuelo.test. (
                     2026101502  ; serial: subido porque hay cambios
                     3600        ; refresh
                     900         ; retry
                     604800      ; expire
                     3600 )      ; TTL negativo

; --- Servidores de nombres y correo ---
@         IN  NS     ns1.jamones-guijuelo.test.
@         IN  NS     ns2.jamones-guijuelo.test.
@         IN  MX     10 correo.jamones-guijuelo.test.

; --- El propio dominio abre la web ---
@         IN  A      10.10.20.30

; --- Equipos ---
ns1       IN  A      10.10.20.10
ns2       IN  A      10.10.20.11
servidor  IN  A      10.10.20.10
copia     IN  A      10.10.20.11
correo    IN  A      10.10.20.10                ; A (no CNAME) porque lo usa el MX
www       IN  A      10.10.20.30
impresora IN  A      10.10.20.25

; --- Alias ---
intranet  IN  CNAME  servidor.jamones-guijuelo.test.
ftp       IN  CNAME  copia.jamones-guijuelo.test.
```

## Ampliación: zona inversa `20.10.10.in-addr.arpa`

```text
$TTL 86400
@    IN  SOA  ns1.jamones-guijuelo.test. admin.jamones-guijuelo.test. (
              2026101501 3600 900 604800 3600 )
@    IN  NS   ns1.jamones-guijuelo.test.
@    IN  NS   ns2.jamones-guijuelo.test.

10   IN  PTR  servidor.jamones-guijuelo.test.    ; 10.10.20.10
11   IN  PTR  copia.jamones-guijuelo.test.       ; 10.10.20.11
25   IN  PTR  impresora.jamones-guijuelo.test.   ; 10.10.20.25
30   IN  PTR  www.jamones-guijuelo.test.         ; 10.10.20.30
```

> Lo habitual es **un PTR por IP**, con el nombre principal del equipo. No hace falta un PTR para `ns1` o `correo`, que comparten IP con `servidor`.

## Pregunta de cierre

**Si cargas el fichero original en BIND, ¿cuáles de estos errores harían que la zona no cargue y cuáles solo darían resultados incorrectos?**

- Impiden cargar la zona o dan error al comprobarla: la IP `300` (6), el CNAME junto a otros registros en `@` y en `ftp` (4 y 9), y el NS sin registro A (5).
- La zona carga, pero funciona mal: la falta de punto final (1), la @ en el correo del SOA (2: BIND la toma como un carácter más del nombre), el serial sin subir (3: el primario va bien, los secundarios se quedan atrás) y el PTR en la zona directa (10: crea un nombre absurdo, `25.jamones-guijuelo.test`).
- Depende de la configuración: el MX a un CNAME (7) y el CNAME a una IP (8). BIND puede cargarlos con avisos, pero no funcionan como se espera.

> ⚠️ Esta clasificación es orientativa: no la he comprobado con `named-checkzone`. Merece la pena hacerlo en la práctica con el fichero original: así el alumnado ve los mensajes reales de BIND.