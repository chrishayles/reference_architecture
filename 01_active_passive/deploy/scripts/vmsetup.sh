# Wait for other processes to finish
echo "Sleeping for 1 minute..."
sleep 1m

# Export args to environment variables
# export K8S_VERSION=$1
export  MAN_ID=$1
export  AKS_NAME=$2
export  AKS_RG=$3

# Install Azure cli
echo "Installing Azure cli"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash


# # Install kubectl
# echo "Installing kubectl v" + $K8S_VERSION
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v$K8S_VERSION/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# sudo mv ./kubectl /usr/local/bin/kubectl
# kubectl version --client -o yaml

# Install jq
sudo apt-get update && sudo apt-get install -y jq

#METADATA=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute?api-version=2017-08-01")
#TOKEN=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -s -H Metadata:true | jq -r .access_token)
#RG=$(echo $METADATA | jq -r .resourceGroupName)
#SID=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute?api-version=2017-08-01" | jq -r .subscriptionId)
#AKS=$(az aks list -g $RG | jq -r .[0].name)

az aks install-cli
az aks get-credentials -g $AKS_RG -n $AKS_NAME

kubectl get namespaces