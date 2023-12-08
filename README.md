

## Les inscriptions et explications pour déployer l'infrastructure et l'application sur Azure

### 1. Déployer les ressources sur Terraform

Il faut se mettre dans le répertoire **terraform** pour cette partie.

> $ cd terraform

Connectez-vous avec azure CLI :
> $ az login

***!! Renseignez le fichier `terraform.tfvars` et modifiez la valeurs de variables dans ce fichier si vous souhaitez.***

Initializez votre environement d'excécution Terraform, cela permet de télécharger les plugins et modules décrits dans les fichiers de configuration :

Le fichier `main.tf` contient principalement la configuration.
> $ terraform init

Visualisez les changements de configuration avant de les appliquer à Azure :
> $ terraform plan

Si les changements sont corrects, appliquez les avec cette commande et confirmez l'exécution :
> $ terraform apply

Allez sur le portail Azure pour vérifier les ressources créées : <a>
https://portal.azure.com/
</a>

Au cas de besoin, détruisez les ressources dans la configuration avec :
> $ terraform destroy
### 2. Push de l'image Docker sur le Container Resgistry dans Azure

Il faut se mettre dans le répertoire **flask-app** pour cette partie.

> $ cd flask-app

Connectez-vous à votre conteneur de registre ***<container_registry_name>*** :
> $ az arc login --name arcesgimaithi

Démarrez les services définis dans le fichier `docker-compose.yml`:
> $ docker-compose up -d

Vérifiez si l'image `flask-app-app` est bien créée :
> $ docker image ls

Tag l'image avec le nom du serveur pour le resgitry, le format du nom ***<container_registry_name>.azurecr.io*** :
> $ docker tag flask-app-app arcesgimaithi.azurecr.io/flask-app-app

Push l'image sur la ressource ACR :
> $ docker push arcesgimaithi.azurecr.io/flask-app-app




