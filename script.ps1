# Execution en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


Write-Output "Veuillez choisir une option"
Write-Output "1. Configurer le serveur"
Write-Output "2. Configurer le domaine"    
Write-Output "3. Créer des OU et des utilisateurs"

$choix = Read-Host "Choix (1, 2, 3)"
switch ($choix) {
    "1" { Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `".\1_PostInstall\script.ps1`"" -Verb RunAs }
    "2" { Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `".\2_ADDS\script.ps1`"" -Verb RunAs }
    "3" { Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `".\3_OU-user\script.ps1`"" -Verb RunAs }
    default { Write-Output "Option inconnue" }
}