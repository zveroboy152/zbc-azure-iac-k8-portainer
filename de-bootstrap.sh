#!/bin/bash

# This script deletes all resources created by the build script

echo "Deleting resources created by build script..."

# Set variables
subscription="84d9ff66-efb7-49ce-bbca-e4ea915b5d86"
resource_group_name="zbc-aks-wordpress-dev"
aks_name="zbc-aks-dev"
location="westus3"

echo "Setting subscription..."

# Set subscription
az account set --subscription $subscription || {
    echo "Error: Failed to set subscription"
    exit 1
}

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

echo "Deleting AKS cluster..."

# Delete the AKS cluster
az aks delete --resource-group $resource_group_name --name $aks_name --yes || {
    echo "Error: Failed to delete AKS cluster"
    exit 1
}

echo "Deleting resource group..."

# Delete the resource group
az group delete --name $resource_group_name --yes || {
    echo "Error: Failed to delete resource group"
    exit 1
}

echo "Resources deleted successfully!"