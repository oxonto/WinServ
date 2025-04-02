#Variables de configuration
$path = "3_OU-user\import.csv"


# Execution en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


#Variables d'éxecution
$users = import-csv -path $path -delimiter ","
$listOU = $users | Select-Object -ExpandProperty ou | Sort-Object -Unique
$ADDomain = (Get-ADDomain).DistinguishedName
$Domain = (Get-ADDomain).Forest


#Création des OU
foreach($eachOU in $listOU)
{
    New-ADOrganizationalUnit -Name "$eachOU" -Path "$ADDomain" -ProtectedFromAccidentalDeletion $false
}


#Création des utilisateurs
foreach($user in $users)
{
    $nom = $user.nom
    $prenom = $user.prenom
    $ou = $user.ou
    $password = $user.password


    $nomComplet = $prenom + " " +$nom
    $idSAM = $prenom.substring(0,1) + $nom
    $id = $idSAM + "@$Domain"

    $pass= ConvertTo-SecureString "$password" -AsPlaintext -Force

    New-ADUser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=$ou,$ADDomain" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
}