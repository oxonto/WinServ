Le présent script simplifie la création des OU et des Utilisateurs dans un Windows Server.
Il fonctionne en doublon avec un fichier CSV pour la création des OU et l'import des Utilisateurs.

Le fichier CSV nécessite quatre colonnes : "prenom" pour le prénom, "nom" pour le nom de famille, "password" pour le mot de passe, "ou" pour l'unité d'organisation.
Le fichier CSV doit se trouver dans le même répertoire que le script pour une utilisation simplifié.

[Voir fichier CSV](import.csv)

### *(testé sur Windows Server 2022)*