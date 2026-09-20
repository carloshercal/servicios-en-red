# Práctica de Subnetting — Repaso de Redes Locales (1º)

Módulo: Servicios en Red · 2º CFGM Sistemas Microinformáticos y Redes

## 1. Recordatorio del método

- **Paso 1 · Identifica el requisito.** ¿Te piden un número de subredes, un número de hosts por subred, o ambos?
- **Paso 2 · Calcula los bits necesarios.** Si te dan el nº de hosts: busca el menor n tal que 2ⁿ − 2 ≥ hosts necesarios. Si te dan el nº de subredes: busca el menor n tal que 2ⁿ ≥ subredes necesarias (bits prestados).
- **Paso 3 · Calcula la nueva máscara.** Bits de red totales = bits de red originales + bits prestados.
- **Paso 4 · Calcula el salto entre redes (tamaño de bloque).** Salto = 2^(bits de host que quedan) = 256 − (octeto de la máscara que cambia).
- **Paso 5 · Enumera las subredes.** Broadcast = siguiente red − 1 · Primer host = red + 1 · Último host = broadcast − 1 · Hosts útiles = salto − 2.

## 2. Ejercicio modelo (resuelto paso a paso)

**Enunciado:** dada la red 192.168.10.0/24, es necesario obtener 8 subredes de 30 hosts cada una.

- Bits de host: 2⁵ − 2 = 30 → 5 bits. Comprobación por subredes: 2³ = 8 → 3 bits prestados (3+5=8, coherente).
- Máscara: /27 → 255.255.255.224. Salto: 256 − 224 = 32.

| Nº | Red (net) | Máscara | Broadcast | Primer host | Último host | Hosts útiles |
|---|---|---|---|---|---|---|
| 1 | 192.168.10.0 | 255.255.255.224 | 192.168.10.31 | 192.168.10.1 | 192.168.10.30 | 30 |
| 2 | 192.168.10.32 | 255.255.255.224 | 192.168.10.63 | 192.168.10.33 | 192.168.10.62 | 30 |
| 3 | 192.168.10.64 | 255.255.255.224 | 192.168.10.95 | 192.168.10.65 | 192.168.10.94 | 30 |
| 4 | 192.168.10.96 | 255.255.255.224 | 192.168.10.127 | 192.168.10.97 | 192.168.10.126 | 30 |
| 5 | 192.168.10.128 | 255.255.255.224 | 192.168.10.159 | 192.168.10.129 | 192.168.10.158 | 30 |
| 6 | 192.168.10.160 | 255.255.255.224 | 192.168.10.191 | 192.168.10.161 | 192.168.10.190 | 30 |
| 7 | 192.168.10.192 | 255.255.255.224 | 192.168.10.223 | 192.168.10.193 | 192.168.10.222 | 30 |
| 8 | 192.168.10.224 | 255.255.255.224 | 192.168.10.255 | 192.168.10.225 | 192.168.10.254 | 30 |

## 3. Ejercicio 1 (resuelto)

**Enunciado:** dada la red 192.168.20.0/24, es necesario obtener 4 subredes con capacidad para 50 hosts cada una.

- Bits de host: 2⁶ − 2 = 62 ≥ 50 → 6 bits de host.
- Máscara: /26 → 255.255.255.192. Salto: 256 − 192 = 64.
- Nº de subredes que caben: 2^(8−6) = 4 → coincide exactamente con lo pedido.

| Nº | Red (net) | Máscara | Broadcast | Primer host | Último host | Hosts útiles |
|---|---|---|---|---|---|---|
| 1 | 192.168.20.0 | 255.255.255.192 | 192.168.20.63 | 192.168.20.1 | 192.168.20.62 | 62 |
| 2 | 192.168.20.64 | 255.255.255.192 | 192.168.20.127 | 192.168.20.65 | 192.168.20.126 | 62 |
| 3 | 192.168.20.128 | 255.255.255.192 | 192.168.20.191 | 192.168.20.129 | 192.168.20.190 | 62 |
| 4 | 192.168.20.192 | 255.255.255.192 | 192.168.20.255 | 192.168.20.193 | 192.168.20.254 | 62 |
