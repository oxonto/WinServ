# Execution en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


# Demander le nom de domaine
$DomainName = Read-Host "Entrez le nom du domaine (ex: monentreprise.local)"
$SafeModePassword = Read-Host "Entrez le mot de passe du mode restauration DSRM (Active Directory)" -AsSecureString


# Installer les rôles AD DS et DNS
if (-not (Get-WindowsFeature -Name AD-Domain-Services | Where-Object Installed)) {
    Write-Output "Installation du role AD DS en cours..."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature
    Write-Output "Installation du role AD DS terminé"
}

if (-not (Get-WindowsFeature -Name DNS | Where-Object Installed)) {
    Write-Output "Installation du role DNS en cours..."
    Install-WindowsFeature -Name DNS -IncludeManagementTools -IncludeAllSubFeature
    Write-Output "Installation du role DNS terminé"
}


# Configurer le premier contrôleur de domaine de la forêt
Get-ADDomain 
if ($?) {
    Write-Host "AD DS déjà configuré !" -ForegroundColor Green
    pause
    } 
else 
    {
    Write-Output "Configuration AD DS en cours..."
    Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -InstallDns -Confirm:$false -Force
    Write-Output "Configuration AD DS terminé"
    Restart-Computer -Force
}