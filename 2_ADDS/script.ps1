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
    Write-Host "Installation du role AD DS terminé" -ForegroundColor Green
}

if (-not (Get-WindowsFeature -Name DNS | Where-Object Installed)) {
    Write-Host "Installation du role DNS en cours..." -ForegroundColor Green
    Install-WindowsFeature -Name DNS -IncludeManagementTools -IncludeAllSubFeature
    Write-Host "Installation du role DNS terminé" -ForegroundColor Green
}


# Configurer le premier contrôleur de domaine de la forêt
try {
    Get-ADDomain -ErrorAction SilentlyContinue 
    Write-Host "AD DS déjà configuré !" -ForegroundColor Green
    pause
    } 
catch 
    {
    Write-Host "Configuration AD DS en cours..." -ForegroundColor Green
    Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -InstallDns -Confirm:$false -Force
    Write-Host "Configuration AD DS terminé" -ForegroundColor Green
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}