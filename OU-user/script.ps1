#Variables de configuration
$path = ".\import.csv"
$domain = "h35.lan"


#Variables d'éxecution
$users = import-csv -path $path -delimiter ","
$listOU = $users | Select-Object -ExpandProperty ou | Sort-Object -Unique
$DC1, $DC2 = $domain -split "\."
$DC = "DC=$DC1,DC=$DC2"

#Création des OU
foreach($eachOU in $listOU)
{
    New-ADOrganizationalUnit -Name "$eachOU" -Path "$DC" -ProtectedFromAccidentalDeletion $false
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
    $id = $idSAM + "@$domain"

    $pass= ConvertTo-SecureString "$password" -AsPlaintext -Force

    New-ADUser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=$ou,$DC" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
}