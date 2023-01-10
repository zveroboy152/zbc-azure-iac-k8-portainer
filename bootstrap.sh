#!/bin/bash

# Set variables
subscription=""
resource_group_name=""
aks_name=""
location=""


echo "Deploying Portainer on Azure AKS..."

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
if ! command -v helm > /dev/null; then
    echo "Error: helm is not installed"
    exit 1
fi
echo "Validating resource group name..."

# Validate resource group name
if ! [[ "$resource_group_name" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
    echo "Error: Invalid resource group name"
    exit 1
fi
# Setting subscription
echo "Setting subscription"
az account set --subscription  $subscription  || {
    echo "Error: Setting the subscription failed."
    exit 1
}


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
az aks get-credentials --resource-group $resource_group_name --name $aks_name  --overwrite-existing || {
    echo "Error: Failed to retrieve AKS credentials"
    exit 1
}

# Install the HELM repo and update repo

helm repo add portainer https://portainer.github.io/k8s/ || {
    echo "Error:Failed to add Portainer Repo"
    exit 1
}
helm repo update || {
    echo "Error:Failed to Update the helm repos that are currently added."
    exit 1
}

# Install Portainer
kubectl create namespace portainer|| {
    echo "Error:Failed to create namespace Portainer"
    exit 1
}
helm install -n portainer portainer portainer/portainer --set service.type=LoadBalancer|| {
    echo "Error: Failed to deploy Portainer"
    exit 1
}

echo "Portainer has been deployed!

If your portainer GUIs ADMIN signup page has timed out, please restart the service:

-Get your pods
kubectl get pods -n portainer

-Reset the pods 'replace the pod name with your own pod name'
kubectl get pod portainer-579f4c744d-95h6b -n portainer  -o yaml | kubectl replace --force -f -

"
