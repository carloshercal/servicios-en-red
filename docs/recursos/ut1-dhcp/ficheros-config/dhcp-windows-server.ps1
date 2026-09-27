# =====================================================================
#  dhcp-windows-server.ps1 — Equivalente en PowerShell de la práctica UT1-P1
#  Módulo: Servicios en Red · 2º SMR · UT1 DHCP
#  Ruta en el repo: recursos/ut1-dhcp/ficheros-config/dhcp-windows-server.ps1
#
#  Escenario (red interna net01, 192.168.10.0/24):
#    - Servidor DHCP WIN25-SER (Windows Server 2025) .. 192.168.10.100
#    - Router Debian 12 (gateway) ..................... 192.168.10.254
#    - Ámbito 192.168.10.1 – .150, excluido .51 – .149 → reparto dinámico .1 – .50
#    - Reserva cliente-debian .......................... 192.168.10.150
#
#  CÓMO USARLO: NO lo ejecutes entero de una vez. Copia y ejecuta cada bloque
#  en PowerShell como Administrador, en orden, y comprueba el resultado antes
#  de pasar al siguiente. El bloque 1 reinicia el servidor.
#  Todo lo que se hace aquí se puede hacer también desde el Administrador del
#  servidor y la consola DHCP (dhcpmgmt.msc), como en la práctica guiada.
# =====================================================================


# ---------------------------------------------------------------------
# BLOQUE 1 · Cambiar el nombre del servidor (Paso 1 · RA1.d)
# ---------------------------------------------------------------------
Rename-Computer -NewName "WIN25-SER" -Restart      # Cambia el nombre y reinicia


# ---------------------------------------------------------------------
# BLOQUE 2 · IP estática del servidor (Paso 2 · RA1.e)
# ---------------------------------------------------------------------
Get-NetAdapter                                      # Mira el nombre del adaptador (columna Name)
$if = "Ethernet"                                    # Cámbialo si tu adaptador se llama distinto

Set-NetIPInterface -InterfaceAlias $if -Dhcp Disabled          # Desactiva el cliente DHCP en esa interfaz
New-NetIPAddress -InterfaceAlias $if `
    -IPAddress 192.168.10.100 -PrefixLength 24 `
    -DefaultGateway 192.168.10.254                              # IP fija, máscara /24 y puerta de enlace
Set-DnsClientServerAddress -InterfaceAlias $if `
    -ServerAddresses 10.151.123.21, 10.151.126.21               # DNS de Educacyl: primario y secundario

Get-NetIPConfiguration -InterfaceAlias $if          # Comprobación: IPv4Address, IPv4DefaultGateway, DNSServer


# ---------------------------------------------------------------------
# BLOQUE 3 · Instalar el rol Servidor DHCP (Paso 3 · RA1.d)
# ---------------------------------------------------------------------
Install-WindowsFeature -Name DHCP -IncludeManagementTools       # Instala el rol y la consola DHCP

netsh dhcp add securitygroups                        # Crea los grupos locales «Administradores de DHCP» y «Usuarios de DHCP»
Restart-Service -Name DHCPServer                    # Reinicia el servicio para que use esos grupos

# Sin dominio de Active Directory no hace falta autorizar el servidor. Esta
# línea marca como terminada la configuración posinstalación, para que el
# Administrador del servidor deje de mostrar el aviso amarillo.
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12" `
    -Name ConfigurationState -Value 2

Get-Service -Name DHCPServer                         # Comprobación: Status = Running


# ---------------------------------------------------------------------
# BLOQUE 4 · Crear el ámbito, la exclusión y las opciones (Paso 4 · RA1.e, RA1.g)
# ---------------------------------------------------------------------
Set-DhcpServerv4Binding -InterfaceAlias $if -BindingState $true   # Enlaza el servicio a la interfaz de net01

Add-DhcpServerv4Scope -Name "smr2ser.org" `
    -StartRange 192.168.10.1 -EndRange 192.168.10.150 `
    -SubnetMask 255.255.255.0 `
    -LeaseDuration 8.00:00:00 `
    -State Active                                   # Ámbito .1 – .150, concesión de 8 días, ya activado
                                                    # Su identificador (ScopeId) es la red: 192.168.10.0

Add-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0 `
    -StartRange 192.168.10.51 -EndRange 192.168.10.149   # Exclusión intermedia: el reparto dinámico queda en .1 – .50

Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 `
    -Router 192.168.10.254 `
    -DnsServer 10.151.123.21, 10.151.126.21 `
    -DnsDomain "smr2ser.org" `
    -Force                                          # Opciones 3 (router), 6 (DNS de Educacyl) y 15 (dominio)
                                                    # -Force: no comprueba si los DNS responden (así no falla si el router aún no da salida)


# ---------------------------------------------------------------------
# BLOQUE 5 · Reserva para el cliente Debian (Paso 5 · RA1.f)
# ---------------------------------------------------------------------
# La MAC es FICTICIA: pon la real del cliente Debian (ip link → link/ether).
# En Windows se escribe con guiones: 08-00-27-AA-BB-CC.
Add-DhcpServerv4Reservation -ScopeId 192.168.10.0 `
    -IPAddress 192.168.10.150 `
    -ClientId "08-00-27-AA-BB-CC" `
    -Name "cliente-debian" `
    -Type Both                                      # Reserva .150 para esa MAC (DHCP y BOOTP)


# ---------------------------------------------------------------------
# BLOQUE 6 · Regla de firewall para permitir ping (Paso 6)
# ---------------------------------------------------------------------
New-NetFirewallRule -DisplayName "Habilitar PING a Windows Server" `
    -Direction Inbound -Protocol ICMPv4 -IcmpType 8 `
    -Action Allow                                   # Permite «echo request» (tipo 8) entrante, todos los perfiles


# ---------------------------------------------------------------------
# BLOQUE 7 · Tarea de entrega: exclusiones adicionales
# ---------------------------------------------------------------------
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0 `
    -StartRange 192.168.10.50 -EndRange 192.168.10.50    # Servidor de BBDD → reparto dinámico real: .1 – .49

# 192.168.10.75 (Firewall) YA está dentro de la exclusión .51 – .149, así que
# no hace falta añadirla. Si se intenta, la consola puede rechazarla por
# solaparse con la exclusión que ya existe.
# Add-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0 -StartRange 192.168.10.75 -EndRange 192.168.10.75


# ---------------------------------------------------------------------
# BLOQUE 8 · Verificación en el servidor (Pasos 7 y 8 · RA1.h)
# ---------------------------------------------------------------------
Get-DhcpServerv4Scope                                       # Ámbito: rango, máscara, estado (Active) y duración
Get-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0        # Exclusiones: .51–.149 y .50
Get-DhcpServerv4OptionValue   -ScopeId 192.168.10.0         # Opciones 3, 6 y 15 con sus valores
Get-DhcpServerv4Reservation   -ScopeId 192.168.10.0         # Reserva .150 ↔ MAC del cliente Debian
Get-DhcpServerv4Lease         -ScopeId 192.168.10.0 |
    Format-Table IPAddress, ClientId, HostName, AddressState, LeaseExpiryTime   # Concesiones activas y cuándo caducan
