#!/bin/bash

echo "Redeploying MySQL with fixed configuration..."

# Delete existing MySQL resources
echo "1. Deleting existing MySQL deployment..."
kubectl delete deployment mysql --ignore-not-found=true

echo "2. Deleting existing MySQL service..."
kubectl delete service mysql --ignore-not-found=true

echo "3. Deleting existing MySQL init ConfigMap..."
kubectl delete configmap mysql-init --ignore-not-found=true

# Wait for resources to be fully deleted
echo "4. Waiting for resources to be deleted..."
sleep 5

# Apply updated configurations
echo "5. Applying MySQL init ConfigMap..."
kubectl apply -f k8s/mysql-init-configmap.yml

echo "6. Applying MySQL deployment..."
kubectl apply -f k8s/mysql-deployment.yml

echo "7. Applying MySQL service..."
kubectl apply -f k8s/mysql-service.yml

# Wait for MySQL to be ready
echo "8. Waiting for MySQL pod to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# Restart backend pods to reconnect with new MySQL
echo "9. Restarting backend pods..."
kubectl rollout restart deployment backend

echo "10. Waiting for backend pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s

echo ""
echo "✅ MySQL redeployment complete!"
echo ""
echo "To check the status, run:"
echo "  kubectl get pods"
echo ""
echo "To check backend logs, run:"
echo "  kubectl logs -l app=backend --tail=50"
