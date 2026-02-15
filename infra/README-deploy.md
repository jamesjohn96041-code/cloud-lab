# Cloud Lab - Azure Container Apps Deploy (when subscription available)

## Prereqs
- Azure CLI logged in
- Resource group + Container Apps Environment created

## Variables
export RG=cloud-lab-rg
export LOC=eastus
export ENV=cloud-lab-env

## Create RG
az group create -n $RG -l $LOC

## Create Container Apps environment
az containerapp env create -n $ENV -g $RG -l $LOC

## Deploy backend (private)
az containerapp create \
  -n cloud-lab-backend \
  -g $RG \
  --environment $ENV \
  --image jame030604/cloud-lab-backend:latest \
  --ingress internal \
  --target-port 5000 \
  --env-vars DATABASE_URL="<AZURE_POSTGRES_DATABASE_URL>"

## Get backend internal FQDN
az containerapp show -n cloud-lab-backend -g $RG --query properties.configuration.ingress.fqdn -o tsv

## Deploy frontend (public) - point to backend via internal FQDN
# (We bake the backend base URL into nginx.conf in the image OR use env + template)
az containerapp create \
  -n cloud-lab-frontend \
  -g $RG \
  --environment $ENV \
  --image jame030604/cloud-lab-frontend:latest \
  --ingress external \
  --target-port 80
