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

# Deploy Wordpress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/wordpress/mysql-deployment.yaml || {
    echo "Error: Failed to deploy MySQL"
    exit 1
}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/wordpress/wordpress-deployment.yaml || {
    echo "Error: Failed to deploy Wordpress"
    exit 1
}

echo "Exposing Wordpress service..."

# Expose Wordpress service
kubectl expose deployment wordpress --type=LoadBalancer --port=80 --target-port=80 || {
    echo "Error: Failed to expose Wordpress service"
    exit 1
}

echo "Wordpress deployed successfully!"