

## Les inscriptions et explications pour déployer l'infrastructure et l'application sur Azure

### 1. Déployer les ressources sur Terraform

#### Précision

Certaines des commandes utilisent la création de variables. Si vous utilisez un environnement powershell,
voici comment créer une variable sous powershell:

```shell
$MAVARIABLE=mavaleur
```


Il faut se mettre dans le répertoire **terraform** pour cette partie.

```bash
$ cd terraform
```

Connectez-vous avec azure CLI :
```bash
$ az login
```

***!! Renseignez le fichier `terraform.tfvars` et modifiez la valeurs de variables dans ce fichier si vous souhaitez.***

Initializez votre environement d'excécution Terraform, cela permet de télécharger les plugins et modules décrits dans les fichiers de configuration :

Le fichier `main.tf` contient principalement la configuration.
```bash
$ terraform init -upgrade
```

Visualisez les changements de configuration avant de les appliquer à Azure :
```bash
$ terraform plan
```

Si les changements sont corrects, appliquez les avec cette commande et confirmez l'exécution :
```bash
$ terraform apply
```
Stocker l'adresse IP publique dans une variable.
```bash
$ PUBLIC_IP=$(terraform output public_ip)
```

Allez sur le portail Azure pour vérifier les ressources créées : <a>
https://portal.azure.com/
</a>

### 2. Push de l'image Docker sur le Container Resgistry dans Azure

Il faut se mettre dans le répertoire **flask-app** pour cette partie et allumer docker.
```bash
$ cd ../flask-app
```

Connectez-vous à votre conteneur de registre ***<container_registry_name>*** :
```bash
$ az acr login --name acresgimaithi
```

Build et push de l'image de l'application **flask-app** avec un processeur ARM:
```bash
$ docker buildx build --platform linux/amd64,linux/arm64 -t acresgimaithi.azurecr.io/flask-app:v1 --push .
```

Build et push de l'image de l'application **flask-app** sans un processeur ARM:

Build:
```bash
docker build -t acresgimaithi.azurecr.io/flask-app:v1 .
```

Push:
```bash
$ docker push acresgimaithi.azurecr.io/flask-app:v1 
```

### 3. Deploy l'application avec Kubernetes

Il faut se mettre dans le répertoire **kubernetes** pour cette partie.
```bash
$ cd ../kubernetes
$ az aks get-credentials --overwrite-existing -n aksesgimaithi -g rg-esgi-maithi

$ ACR_NAME=acresgimaithi
$ SERVICE_PRINCIPAL_NAME=flask-app-esgimaithi
$ ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
$ PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
$ USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

$ NAMESPACE=ingress-basic
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo update
$ helm install nginx-ingress ingress-nginx/ingress-nginx \   
    --create-namespace \
    --namespace $NAMESPACE \
    --set controller.service.loadBalancerIP=$PUBLIC_IP \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"="/healthz"

$ kubectl create secret docker-registry secret-pull \
    --namespace $NAMESPACE \
    --docker-server=acresgimaithi.azurecr.io \
    --docker-username=$USER_NAME \
    --docker-password=$PASSWORD

$ kubectl apply -f flask-app-ingress.yaml
$ kubectl apply -f flask-app-deployment.yaml
$ kubectl apply -f flask-app-service.yaml
$ kubectl apply -f redis-deployment.yaml
$ kubectl apply -f redis-service.yaml
```
Vérifiez si tout fonctionne bien :
```bash
TEST=$(echo $PUBLIC_IP | tr -d '"')
curl $TEST
```

Au cas de besoin, détruisez les ressources dans la configuration avec :
```bash
$ terraform destroy
```



