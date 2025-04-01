#Variables de configuration
$path = ".\import.csv"
$domain = "h35.lan"
$password = "Zqsd@2024"


#Variables d'éxecution
$users = import-csv -path $path -delimiter ","
$ous = $users | Select-Object -ExpandProperty ou | Sort-Object -Unique
$DC1, $DC2 = $domain -split "\."
$DC = "DC=$DC1,DC=$DC2"

#Création des OU
foreach($ou in $ous)
{
    New-ADOrganizationalUnit -Name "$ou" -Path "$DC" -ProtectedFromAccidentalDeletion $false
}

#Création des utilisateurs
foreach($user in $users)
{
    $nom = $user.nom
    $prenom= $user.prenom
    $unitgroup = $user.ou

    $nomComplet = $prenom + " " +$nom
    $idSAM = $prenom.substring(0,1) + $nom
    $id = $idSAM + "@$domain"

    $pass= ConvertTo-SecureString "$password" -AsPlaintext -Force

    New-ADUser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=$unitgroup,$DC" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
}