# Export args to environment variables
export  MAN_ID=$1
export  AKS_NAME=$2
export  AKS_RG=$3
export  ADMIN_ACCT=$4
export  STATIC_IP=$5

echo "Passed arguments:"
echo "MAN_ID=$1"
echo "AKS_NAME=$2"
echo "AKS_RG=$3"
echo "ADMIN_ACCT=$4"
echo "STATIC_IP=$5"

# Wait for other processes to finish
echo "Sleeping for 1 minute..."
sleep 1m

# Install Azure cli
echo "Installing Azure cli"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Log in Azure cli
echo "Logging into Azure cli"
sudo runuser -l $ADMIN_ACCT -c "az login --identity -u $MAN_ID"

# Install kubectl
echo "Installing kubectl"
sudo runuser -l $ADMIN_ACCT -c "sudo az aks install-cli"

# Get kube credential
echo "Getting .kube/config"
sudo runuser -l $ADMIN_ACCT -c "az aks get-credentials -g $AKS_RG -n $AKS_NAME"

echo "Done"

# Get Helm
echo "Get Helm"
wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz 

# Untar Helm
echo "Untar Helm"
tar -zxvf helm-v2.16.9-linux-amd64.tar.gz 

# Move Helm
echo "Move Helm"
sudo mv ./linux-amd64/helm /usr/local/bin/helm

# Create Tiller RBAC
echo "Create Tiller service account"
sudo runuser -l $ADMIN_ACCT -c "kubectl -n kube-system create serviceaccount tiller"

echo "Create Tiller cluster role binding"
sudo runuser -l $ADMIN_ACCT -c "kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller"

echo "Helm init"
sudo runuser -l $ADMIN_ACCT -c "helm init --service-account tiller"

# Create a namespace for your ingress resources
echo "Create namespace"
sudo runuser -l $ADMIN_ACCT -c "kubectl create namespace nginx"

# Add the official stable repository
echo "Add stable repo to Helm"
sudo runuser -l $ADMIN_ACCT -c "helm repo add stable https://kubernetes-charts.storage.googleapis.com/"

# Use Helm to deploy an NGINX ingress controller
# echo "Deploy ingress"
# sudo runuser -l $ADMIN_ACCT -c "helm install --name nginx-ingress stable/nginx-ingress \
#     --namespace nginx \
#     --set controller.replicaCount=2 \
#     --set controller.nodeSelector.\"beta\.kubernetes\.io/os\"=linux \
#     --set defaultBackend.nodeSelector.\"beta\.kubernetes\.io/os\"=linux \
#     --set controller.service.loadBalancerIP=\"$STATIC_IP\" \
#     --set controller.service.annotations.\"service\.beta\.kubernetes\.io/azure-dns-label-name\"=\"demo-aks-ingress\""

# echo "Create LB"
# sudo runuser -l $ADMIN_ACCT -c "az network public-ip create --resource-group $AKS_RG-nodes --name $AKS_NAME-pip --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv"


helm install --name nginx-ingress stable/nginx-ingress \
    --namespace nginx \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="$AKS_NAME"