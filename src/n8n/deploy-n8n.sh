#!/bin/bash
# deploy-n8n.sh

echo "🚀 Deploying n8n with PostgreSQL..."

# Passwörter generieren
POSTGRES_PASSWORD=$(openssl rand -base64 32)
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)

echo "📝 Generated secure passwords"

# Namespace erstellen
microk8s kubectl create namespace n8n --dry-run=client -o yaml | microk8s kubectl apply -f -

# Secrets erstellen
microk8s kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_DB=n8n \
  --from-literal=POSTGRES_USER=n8n \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --namespace=n8n \
  --dry-run=client -o yaml | microk8s kubectl apply -f -

microk8s kubectl create secret generic n8n-secret \
  --from-literal=N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY" \
  --from-literal=DB_POSTGRESDB_HOST=postgres-service \
  --from-literal=DB_POSTGRESDB_PORT=5432 \
  --from-literal=DB_POSTGRESDB_DATABASE=n8n \
  --from-literal=DB_POSTGRESDB_USER=n8n \
  --from-literal=DB_POSTGRESDB_PASSWORD="$POSTGRES_PASSWORD" \
  --namespace=n8n \
  --dry-run=client -o yaml | microk8s kubectl apply -f -

echo "🔐 Secrets created"

# Deployment anwenden
microk8s kubectl apply -f n8n-deployment.yaml

echo "✅ Deployment applied"
echo "🔍 Checking status..."
microk8s kubectl get pods -n n8n