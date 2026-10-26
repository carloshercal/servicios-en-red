# =============================================================================
# acceso-remoto-windows-server.ps1
# UT3 · Servicios de acceso remoto · Ejercicios 16 y 17
# Servidor: WIN25-SER · Windows Server 2025 · 192.168.10.100 (net01)
#
# Qué hace:
#   1. Permite el ping (para diagnosticar desde net02).
#   2. Crea el usuario de laboratorio «tecnico» y lo añade a
#      «Usuarios de escritorio remoto».
#   3. Activa Escritorio remoto (RDP) con NLA y abre el cortafuegos.
#   4. Activa el servidor OpenSSH (ya instalado en Windows Server 2025).
#   5. Muestra las comprobaciones.
#
# Uso: PowerShell COMO ADMINISTRADOR, en WIN25-SER:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\acceso-remoto-windows-server.ps1
#
# Los nombres de grupos y reglas se indican por SID o por nombre interno para
# que el script funcione igual en Windows en español o en inglés.
# =============================================================================

# --- 1. Ping (regla «Archivos e impresoras compartidos: petición de eco ICMPv4») ---
Enable-NetFirewallRule -Name "FPS-ICMP4-ERQ-In"

# --- 2. Usuario de laboratorio -----------------------------------------------
# La contraseña se pide por teclado para no dejarla escrita en el script.
# En el laboratorio se usa la contraseña FICTICIA Tecnico.UT3!
if (-not (Get-LocalUser -Name "tecnico" -ErrorAction SilentlyContinue)) {
    $clave = Read-Host -AsSecureString "Contraseña para el usuario tecnico"
    New-LocalUser -Name "tecnico" `
                  -FullName "Técnico de soporte (UT3)" `
                  -Description "Usuario de laboratorio para Escritorio remoto" `
                  -Password $clave `
                  -PasswordNeverExpires                 # evita que caduque durante el curso
}
# S-1-5-32-555 es el SID del grupo integrado «Usuarios de escritorio remoto»
# («Remote Desktop Users» en inglés). Sus miembros pueden entrar por RDP.
Add-LocalGroupMember -SID "S-1-5-32-555" -Member "tecnico" -ErrorAction SilentlyContinue

# --- 3. Escritorio remoto (RDP) -----------------------------------------------
# fDenyTSConnections = 0 → se PERMITEN las conexiones de Escritorio remoto
# (equivale a marcar «Permitir las conexiones remotas a este equipo»).
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
                 -Name "fDenyTSConnections" -Value 0

# UserAuthentication = 1 → se exige NLA (Autenticación a nivel de red):
# las credenciales se comprueban antes de crear la sesión gráfica.
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
                 -Name "UserAuthentication" -Value 1

# Activa las reglas del grupo «Escritorio remoto» del cortafuegos
# (TCP y UDP 3389). Se usa el nombre interno del grupo, igual en todos los idiomas.
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"

# --- 4. Servidor OpenSSH -------------------------------------------------------
# En Windows Server 2025 ya está instalado. En 2019/2022 habría que instalarlo antes:
#   Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name "sshd" -StartupType Automatic       # arranca con el sistema
Start-Service -Name "sshd"                              # lo arranca ahora

# La regla de OpenSSH puede venir activa solo para el perfil «Privado».
# Si la red interna está clasificada como «Pública», las conexiones no llegan.
# SOLO EN EL LABORATORIO se amplía a todos los perfiles:
Get-NetFirewallRule -Name "*OpenSSH*" | Set-NetFirewallRule -Enabled True -Profile Any

# --- 5. Comprobaciones --------------------------------------------------------
Write-Host "`n== Servicios ==" -ForegroundColor Cyan
Get-Service TermService, sshd | Format-Table Name, Status, StartType

Write-Host "== Puertos en escucha (22 y 3389) ==" -ForegroundColor Cyan
netstat -ano | Select-String -Pattern ":22 |:3389 "

Write-Host "== Miembros de Usuarios de escritorio remoto ==" -ForegroundColor Cyan
Get-LocalGroupMember -SID "S-1-5-32-555"

Write-Host "== Perfil de red ==" -ForegroundColor Cyan
Get-NetConnectionProfile | Format-Table InterfaceAlias, NetworkCategory
