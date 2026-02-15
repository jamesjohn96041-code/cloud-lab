#!/usr/bin/env bash
set -euo pipefail

# ====== CHANGE THESE ======
RG="cloud-lab-rg"
LOC="eastus"
ENV="cloud-lab-env"

BACKEND_NAME="cloud-lab-backend"
FRONTEND_NAME="cloud-lab-frontend"

BACKEND_IMAGE="jame030604/cloud-lab-backend:latest"
FRONTEND_IMAGE="jame030604/cloud-lab-frontend:latest"

# Azure Postgres connection string (example)
# Use SSL in Azure
DATABASE_URL="postgresql://<USER>:<PASSWORD>@<PG_HOST>:5432/<DB>?sslmode=require"
# ==========================

echo "Creating resource group..."
az group create -n "$RG" -l "$LOC"

echo "Creating Container Apps environment..."
az containerapp env create -n "$ENV" -g "$RG" -l "$LOC"

echo "Deploying BACKEND (internal ingress)..."
az containerapp create \
  -n "$BACKEND_NAME" \
  -g "$RG" \
  --environment "$ENV" \
  --image "$BACKEND_IMAGE" \
  --ingress internal \
  --target-port 5000 \
  --env-vars DATABASE_URL="$DATABASE_URL"

echo "Fetching backend internal FQDN..."
BACKEND_FQDN=$(az containerapp show -n "$BACKEND_NAME" -g "$RG" --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Backend FQDN: $BACKEND_FQDN"

BACKEND_BASE_URL="http://$BACKEND_FQDN"

echo "Deploying FRONTEND (external ingress) with BACKEND_BASE_URL..."
az containerapp create \
  -n "$FRONTEND_NAME" \
  -g "$RG" \
  --environment "$ENV" \
  --image "$FRONTEND_IMAGE" \
  --ingress external \
  --target-port 80 \
  --env-vars BACKEND_BASE_URL="$BACKEND_BASE_URL"

echo "Fetching frontend URL..."
FRONTEND_URL=$(az containerapp show -n "$FRONTEND_NAME" -g "$RG" --query "properties.configuration.ingress.fqdn" -o tsv)
echo "DONE: https://$FRONTEND_URL"
echo "Test: https://$FRONTEND_URL/api/health"
echo "Test: https://$FRONTEND_URL/api/data"
