# Export args to environment variables
export  MAN_ID=$1
export  AKS_NAME=$2
export  AKS_RG=$3
export  ADMIN_ACCT=$4

echo "Passed arguments:"
echo "MAN_ID=$1"
echo "AKS_NAME=$2"
echo "AKS_RG=$3"
echo "ADMIN_ACCT=$4"

# Wait for other processes to finish
echo "Sleeping for 1 minute..."
sleep 1m

# Install Azure cli
echo "Installing Azure cli"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "Logging into Azure cli"
sudo runuser -l $ADMIN_ACCT -c "az login --identity -u $MAN_ID"

echo "Installing kubectl"
sudo runuser -l $ADMIN_ACCT -c "az aks install-cli"

echo "Getting .kube/config"
sudo runuser -l $ADMIN_ACCT -c "az aks get-credentials -g $AKS_RG -n $AKS_NAME"

echo "Done"