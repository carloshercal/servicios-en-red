# =====================================================================
#  dns-windows-server.ps1 — Equivalente en PowerShell de la práctica UT2-P1
#  Módulo: Servicios en Red · 2º SMR · UT2 DNS
#  Ruta en el repo: recursos/ut2-dns/ficheros-config/dns-windows-server.ps1
#
#  Escenario (red interna net01, 192.168.10.0/24):
#    - WIN25-SER  (Windows Server 2025) .. 192.168.10.100  DHCP + DNS primario (ns1)
#    - WIN25-SER2 (clon de WIN25-SER) .... 192.168.10.200  DNS secundario (ns2)
#    - Router Debian 12 .................. 192.168.10.254
#    - Zona directa  smr2ser.test · zona inversa 10.168.192.in-addr.arpa
#    - Reenviadores: DNS de Educacyl 10.151.123.21 y 10.151.126.21
#
#  CÓMO USARLO: NO lo ejecutes entero de una vez. Copia y ejecuta cada bloque
#  en PowerShell como Administrador, EN EL SERVIDOR QUE INDICA, en orden, y
#  comprueba el resultado antes de pasar al siguiente.
#  El SOA y los NS (bloque 5) se cambian desde la consola dnsmgmt.msc.
# =====================================================================


# ---------------------------------------------------------------------
# BLOQUE 1 · [WIN25-SER] Instalar el rol Servidor DNS (Paso 2 · RA2.d)
# ---------------------------------------------------------------------
Install-WindowsFeature -Name DNS -IncludeManagementTools   # Rol + consola «Administrador de DNS»
Get-Service -Name DNS                                      # Comprobación: Status = Running


# ---------------------------------------------------------------------
# BLOQUE 2 · [WIN25-SER] Zonas directa e inversa (Pasos 3 y 4 · RA2.d)
# ---------------------------------------------------------------------
Add-DnsServerPrimaryZone -Name "smr2ser.test" `
    -ZoneFile "smr2ser.test.dns" `
    -DynamicUpdate None                                    # Zona principal estándar (fichero .dns), sin actualizaciones dinámicas

Add-DnsServerPrimaryZone -NetworkId "192.168.10.0/24" `
    -ZoneFile "10.168.192.in-addr.arpa.dns" `
    -DynamicUpdate None                                    # Zona inversa: Windows la llama 10.168.192.in-addr.arpa

Get-DnsServerZone                                          # Deben aparecer smr2ser.test y 10.168.192.in-addr.arpa (Primary)


# ---------------------------------------------------------------------
# BLOQUE 3 · [WIN25-SER] Registros A, con PTR solo en el nombre principal de cada IP (Paso 5 · RA2.f)
# ---------------------------------------------------------------------
$z = "smr2ser.test"                                        # Zona en la que se crean los registros

Add-DnsServerResourceRecordA -ZoneName $z -Name "win25-ser"  -IPv4Address 192.168.10.100 -CreatePtr   # Servidor primario (+PTR .100)
Add-DnsServerResourceRecordA -ZoneName $z -Name "win25-ser2" -IPv4Address 192.168.10.200 -CreatePtr   # Servidor secundario (+PTR .200)
Add-DnsServerResourceRecordA -ZoneName $z -Name "router"     -IPv4Address 192.168.10.254 -CreatePtr   # Puerta de enlace (+PTR .254)
Add-DnsServerResourceRecordA -ZoneName $z -Name "debiancli"  -IPv4Address 192.168.10.150 -CreatePtr   # Cliente Debian, reserva DHCP (+PTR .150)

Add-DnsServerResourceRecordA -ZoneName $z -Name "ns1"  -IPv4Address 192.168.10.100   # Servidor de nombres primario (sin PTR: la .100 ya tiene)
Add-DnsServerResourceRecordA -ZoneName $z -Name "ns2"  -IPv4Address 192.168.10.200   # Servidor de nombres secundario (sin PTR)
Add-DnsServerResourceRecordA -ZoneName $z -Name "www"  -IPv4Address 192.168.10.100   # Servidor web (UT6)
Add-DnsServerResourceRecordA -ZoneName $z -Name "mail" -IPv4Address 192.168.10.100   # Servidor de correo (UT5); lo usará el MX


# ---------------------------------------------------------------------
# BLOQUE 4 · [WIN25-SER] Registros MX y CNAME (Paso 6 · RA2.f)
# ---------------------------------------------------------------------
Add-DnsServerResourceRecordMX -ZoneName $z -Name "." `
    -MailExchange "mail.smr2ser.test" -Preference 10       # "." = el propio dominio: correo de @smr2ser.test → mail, prioridad 10

Add-DnsServerResourceRecordCName -ZoneName $z -Name "web" -HostNameAlias "www.smr2ser.test"        # Alias web → www
Add-DnsServerResourceRecordCName -ZoneName $z -Name "ftp" -HostNameAlias "win25-ser.smr2ser.test"  # Alias ftp → win25-ser (UT4)

Get-DnsServerResourceRecord -ZoneName $z                   # Lista todos los registros de la zona
Get-DnsServerResourceRecord -ZoneName "10.168.192.in-addr.arpa" -RRType Ptr   # Los 4 PTR: 100, 150, 200 y 254


# ---------------------------------------------------------------------
# BLOQUE 5 · [WIN25-SER] SOA y NS (Paso 7 · RA2.f) → EN LA CONSOLA
# ---------------------------------------------------------------------
# Propiedades de la zona → Inicio de autoridad (SOA):
#     Servidor principal  ns1.smr2ser.test.     Persona responsable  admin.smr2ser.test.
# Propiedades de la zona → Servidores de nombres:
#     Quitar win25-ser. · Agregar ns1.smr2ser.test. (192.168.10.100) · Agregar ns2.smr2ser.test. (192.168.10.200)
# Repetir en la zona inversa 10.168.192.in-addr.arpa.
# Comprobación:
Get-DnsServerResourceRecord -ZoneName $z -RRType SOA      # PrimaryServer = ns1.smr2ser.test.
Get-DnsServerResourceRecord -ZoneName $z -RRType NS       # ns1.smr2ser.test. y ns2.smr2ser.test.


# ---------------------------------------------------------------------
# BLOQUE 6 · [WIN25-SER] Reenviadores y caché (Paso 8 · RA2.e)
# ---------------------------------------------------------------------
Set-DnsServerForwarder -IPAddress 10.151.123.21, 10.151.126.21   # DNS de Educacyl. En casa: 8.8.8.8, 8.8.4.4
Get-DnsServerForwarder                                     # Comprobación: las dos IP y UseRootHint = True

Show-DnsServerCache                                        # Contenido de la caché (tras las consultas del paso 10)
# Clear-DnsServerCache -Force                              # Vaciar la caché del servidor


# ---------------------------------------------------------------------
# BLOQUE 7 · [WIN25-SER] El servidor y el DHCP usan nuestro DNS (Paso 9)
# ---------------------------------------------------------------------
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
    -ServerAddresses 192.168.10.100, 192.168.10.200        # El servidor se pregunta a sí mismo; Educacyl ya es su reenviador

Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 `
    -DnsServer 192.168.10.100, 192.168.10.200 `
    -DnsDomain "smr2ser.test" `
    -Force                                                 # Opción 006 (nuestros DNS) y 015 (nuevo dominio). -Force: .200 aún no existe
Get-DhcpServerv4OptionValue -ScopeId 192.168.10.0          # Comprobación de las opciones 003, 006 y 015

# En los clientes: Windows 7 → ipconfig /release · ipconfig /renew
#                  Debian 12 → sudo dhclient -r && sudo dhclient


# ---------------------------------------------------------------------
# BLOQUE 8 · [WIN25-SER] Guardar las zonas en disco (Paso 10)
# ---------------------------------------------------------------------
dnscmd /writebackfiles                                     # Escribe los ficheros .dns en disco
                                                           # (= consola: clic derecho en el servidor → «Actualizar archivos de datos del servidor»)
Get-Content "$env:SystemRoot\System32\dns\smr2ser.test.dns"   # Ver el fichero de zona (NO editarlo a mano)


# =====================================================================
#  PARTE C · SERVIDOR SECUNDARIO (RA2.g)
#  Antes: apagar WIN25-SER, clonarlo en VirtualBox (clon completo, MAC nuevas)
#  y desmarcar «Cable conectado» en el clon.
# =====================================================================

# ---------------------------------------------------------------------
# BLOQUE 9 · [WIN25-SER2, con el cable desconectado] Convertir el clon (Paso 12)
# ---------------------------------------------------------------------
Uninstall-WindowsFeature -Name DHCP -IncludeManagementTools          # En net01 solo puede haber un servidor DHCP

Remove-DnsServerZone -Name "smr2ser.test" -Force                     # Las zonas copiadas son primarias: se borran
Remove-DnsServerZone -Name "10.168.192.in-addr.arpa" -Force

Remove-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.10.100 -Confirm:$false   # Quita la IP del original
New-NetIPAddress    -InterfaceAlias "Ethernet" -IPAddress 192.168.10.200 -PrefixLength 24  # IP del secundario
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
    -ServerAddresses 192.168.10.200, 192.168.10.100                  # Primero él mismo, luego el primario
Get-NetIPConfiguration -InterfaceAlias "Ethernet"                    # Comprobación: .200 y puerta de enlace .254
# Solo si ha desaparecido la puerta de enlace:
# New-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceAlias "Ethernet" -NextHop 192.168.10.254

Rename-Computer -NewName "WIN25-SER2" -Restart                       # Nuevo nombre y reinicio
# Después: apagar, marcar «Cable conectado» y arrancar los dos servidores.


# ---------------------------------------------------------------------
# BLOQUE 10 · [WIN25-SER] Permitir transferencias y notificar (Paso 13 · RA2.g)
# ---------------------------------------------------------------------
Set-DnsServerPrimaryZone -Name "smr2ser.test" `
    -SecureSecondaries TransferToZoneNameServer `
    -Notify Notify                                         # Transferir solo a los NS de la zona y avisarles de los cambios
Get-DnsServerZone -Name "smr2ser.test" |
    Select-Object ZoneName, SecureSecondaries, Notify      # Comprobación


# ---------------------------------------------------------------------
# BLOQUE 11 · [WIN25-SER2] Zona secundaria (Paso 14 · RA2.g)
# ---------------------------------------------------------------------
Add-DnsServerSecondaryZone -Name "smr2ser.test" `
    -ZoneFile "smr2ser.test.dns" `
    -MasterServers 192.168.10.100                          # Copia de solo lectura de la zona de WIN25-SER

Start-DnsServerZoneTransfer -Name "smr2ser.test"           # Fuerza la transferencia (= «Transferir desde maestro»)
Get-DnsServerResourceRecord -ZoneName "smr2ser.test"       # Deben aparecer todos los registros del primario


# ---------------------------------------------------------------------
# BLOQUE 12 · [WIN25-SER y WIN25-SER2] Comprobar la transferencia (Paso 15 · RA2.g, RA2.h)
# ---------------------------------------------------------------------
Resolve-DnsName smr2ser.test -Type SOA -Server 192.168.10.100 | Select-Object PrimaryServer, SerialNumber   # Serial del primario
Resolve-DnsName smr2ser.test -Type SOA -Server 192.168.10.200 | Select-Object PrimaryServer, SerialNumber   # Serial del secundario: igual

# [WIN25-SER] Cambio en el primario: el serial sube solo
Add-DnsServerResourceRecordCName -ZoneName "smr2ser.test" -Name "intranet" -HostNameAlias "win25-ser.smr2ser.test"

# Repetir los dos Resolve-DnsName: tras el NOTIFY, el secundario tiene el serial nuevo
Resolve-DnsName intranet.smr2ser.test -Server 192.168.10.200          # Lo responde el secundario