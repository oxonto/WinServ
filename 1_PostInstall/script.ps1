# Execution en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


$SrvName = Read-Host "Veuillez entrer le nom du serveur // si vous ne voulez pas le modifier, laissez vide"

$IPAddress = Read-Host "Veuillez entrer l'adresse IP du serveur"

$PrefixLength = Read-Host "Veuillez entrer la masque réseau du serveur en décimal // ex: 24 pour 255.255.255.0"

$Gateway = Read-Host "Veuillez entrer la passerelle du serveur"

$DNSServers = @(Read-Host "Veuillez entrer le(s) DNS du serveur // pour plusieur DNS, separez-les par une virgule")


# Configurer l'adresse IP
$InterfaceAlias = (Get-NetAdapter | Where-Object Up).Name
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -Dhcp Disabled
Disable-NetAdapterBinding -Name $InterfaceAlias -ComponentID ms_tcpip6
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -Confirm:$false
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServers


# Langue de l'installation
$Langue = (Get-WinSystemLocale).Name

# Activer le Bureau à distance
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

if ($Langue -eq "fr-FR") {
        Enable-NetFirewallRule -DisplayGroup "Bureau à distance"
    }
else
    {
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
Restart-Service -Name TermService -Force


# Renommer le serveur
if ($SrvName -eq "") {
        Write-Output "Le serveur ne sera pas renommer"
        Write-Output "Le nom actuel est : $env:COMPUTERNAME"
    } 
else 
    {
    Rename-Computer -NewName "$SrvName" -Force -Restart
}