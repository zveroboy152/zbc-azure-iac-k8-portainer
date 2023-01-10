# AKS Wordpress Deployment

This script deploys a WordPress website on Azure Kubernetes Service (AKS) and installs Portainer for container management.  It will also deploy a fully bootstrapped AKS Cluster in your desired region, and subscriptipn.

## Prerequisites

- Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- kubectl   (This is installed as part of Azure CLI)
- Helm      (https://helm.sh/docs/intro/install/)


## Directions

- Edit the variables in the 'bootstrap.sh' script.
- Run the 'bootstrap.sh' script.


## Usage

```bash
./bootstrap.sh
