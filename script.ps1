#In the CSV file, the first column is the last name "nom", the second is the first name "prenom", and the third is the OU name "ou"
#The CSV file must be in the same directory as the script

$path = ".\import.csv"
$domain = "h35.lan"



$users = import-csv -path $path -delimiter ","
$ous = $users | Select-Object -ExpandProperty ou | Sort-Object -Unique
$DC1, $DC2 = $domain -split "\."
$DC = "DC=$DC1,DC=$DC2"

foreach($ou in $ous)
{
    New-ADOrganizationalUnit -Name "$ou" -Path "$DC" -ProtectedFromAccidentalDeletion $false
}

foreach($user in $users)
{
    $nom = $user.nom
    $prenom= $user.prenom
    $unitgroup = $user.ou

    $nomComplet = $prenom + " " +$nom
    $idSAM = $prenom.substring(0,1) + $nom
    $id = $idSAM + "@$domain"

    $pass= ConvertTo-SecureString "Zqsd@2024" -AsPlaintext -Force

    New-ADUser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=$unitgroup,$DC" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
}