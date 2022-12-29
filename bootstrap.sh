#!/bin/bash

# Set variables
subscription="84d9ff66-efb7-49ce-bbca-e4ea915b5d86"
resource_group_name="zbc-aks-wordpress-dev"
aks_name="zbc-aks-dev"
location="westus3"
echo "Deploying Wordpress on Azure AKS..."
#set subscription
echo "Setting subscription"
az account set --subscription  $subscription

echo "Checking for required Azure CLI tools..."

# Check that the required Azure CLI tools are installed
if ! command -v az > /dev/null; then
    echo "Error: Azure CLI is not installed"
    exit 1
fi

if ! command -v kubectl > /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

echo "Validating resource group name..."

# Validate resource group name
if ! [[ "$resource_group_name" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
    echo "Error: Invalid resource group name"
    exit 1
fi

echo "Creating resource group..."

# Create a resource group
az group create --name $resource_group_name --location $location || {
    echo "Error: Failed to create resource group"
    exit 1
}

echo "Creating AKS cluster..."

# Create an AKS cluster
az aks create --resource-group $resource_group_name --name $aks_name --node-count 1 --generate-ssh-keys || {
    echo "Error: Failed to create AKS cluster"
    exit 1
}

echo "Retrieving AKS credentials..."

# Get AKS credentials
az aks get-credentials --resource-group $resource_group_name --name $aks_name || {
    echo "Error: Failed to retrieve AKS credentials"
    exit 1
}

echo "Deploying Wordpress..."

echo "Installing Helm Tiller on AKS cluster..."

# Install Helm Tiller on the AKS cluster
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller || {
    echo "Error: Failed to install Helm Tiller"
    exit 1
}

echo "Deploying Wordpress using Helm..."

# Deploy Wordpress using Helm
helm install stable/wordpress --set mariadb.persistence.enabled=true --set mariadb.persistence.existingClaim=azure-dynamic-pvc --set wordpressUsername=admin,wordpressPassword=password,mariadb.mariadbRootPassword=password || {
    echo "Error: Failed to deploy Wordpress using Helm"