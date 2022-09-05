#!/bin/bash

# Variables
resourceGroup="cloud-demo"
clusterName="udacity-cluster"

#southcentralus

# Install aks cli
echo "Installing AKS CLI"

az aks install-cli

echo "AKS CLI installed"

# Create AKS cluster
echo "Step 1 - Creating AKS cluster $clusterName"
# Use either one of the "az aks create" commands below
# For users working in their personal Azure account
# This commmand will not work for the Cloud Lab users, because you are not allowed to create Log Analytics workspace for monitoring

# az aks create \
# --resource-group $resourceGroup \
# --name $clusterName \
# --node-count 1 \
# --enable-addons monitoring \
# --generate-ssh-keys

# For Cloud Lab users
az aks create \
--resource-group $resourceGroup \
--name $clusterName \
--node-count 1 \
--generate-ssh-keys \
--node-vm-size Standard_D2s_v3

# For Cloud Lab users
# This command will is a substitute for "--enable-addons monitoring" option in the "az aks create"
# Use the log analytics workspace - Resource ID
# For Cloud Lab users, go to the existing Log Analytics workspace --> Properties --> Resource ID. Copy it and use in the command below.
az aks enable-addons -a monitoring -n $clusterName -g $resourceGroup --workspace-resource-id "/subscriptions/5575e80b-f0da-4822-a386-38229fd50c58/resourceGroups/cloud-demo/providers/Microsoft.OperationalInsights/workspaces/loganalytics-206249"

echo "AKS cluster created: $clusterName"

# Connect to AKS cluster

echo "Step 2 - Getting AKS credentials"

az aks get-credentials  --resource-group cloud-demo  --name udacity-cluster  --verbose

echo "Verifying connection to $clusterName"

kubectl get nodes

# echo "Deploying to AKS cluster"
# The command below will deploy a standard application to your AKS cluster.
# kubectl apply -f azure-vote.yaml

az acr create --resource-group  cloud-demo --name truongcao --sku Basic
az acr login --name truongcao
az acr show --name truongcao --query loginServer --output table
# Associate a tag to the local image. You can use a different tag (say v2, v3, v4, ....) everytime you edit the underlying image.
docker tag azure-vote-front:v1 truongcao.azurecr.io/azure-vote-front:v1
docker push truongcao.azurecr.io/azure-vote-front:v1
az acr repository list --name truongcao --output table
az aks update -n udacity-cluster -g cloud-demo  --attach-acr truongcao
#
kubectl apply -f azure-vote-all-in-one-redis.yaml


az vmss list-instance-connection-info  --resource-group cloud-demo   --name udacity-vmss
ssh -p 50000 udacityadmin@23.100.124.255
