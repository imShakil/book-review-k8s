#!/bin/bash

set -e

echo "=== MySQL Access Fix Script ==="
echo ""

# Delete existing MySQL resources completely
echo "1. Deleting MySQL deployment..."
kubectl delete deployment mysql --ignore-not-found=true --grace-period=0 --force 2>/dev/null || true

echo "2. Deleting MySQL service..."
kubectl delete service mysql --ignore-not-found=true 2>/dev/null || true

echo "3. Deleting MySQL ConfigMap..."
kubectl delete configmap mysql-init --ignore-not-found=true 2>/dev/null || true

echo "4. Deleting any MySQL PVCs (if they exist)..."
kubectl delete pvc -l app=mysql --ignore-not-found=true 2>/dev/null || true

# Wait for complete cleanup
echo "5. Waiting for complete cleanup (15 seconds)..."
sleep 15

# Apply fresh MySQL deployment (without init configmap)
echo "6. Applying fresh MySQL deployment..."
kubectl apply -f k8s/mysql-deployment.yml

echo "7. Applying MySQL service..."
kubectl apply -f k8s/mysql-service.yml

# Wait for MySQL to be ready
echo "8. Waiting for MySQL pod to start..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=180s

echo ""
echo "9. Verifying MySQL user and permissions..."
sleep 5

# Verify the user exists and has correct permissions
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')
echo "   MySQL pod: $MYSQL_POD"

echo ""
echo "   Checking user exists..."
kubectl exec $MYSQL_POD -- mysql -u root -prootpassword -e "SELECT user, host FROM mysql.user WHERE user='bookuser';" 2>/dev/null | grep bookuser && echo "   ✓ User exists"

echo ""
echo "   Checking grants..."
kubectl exec $MYSQL_POD -- mysql -u root -prootpassword -e "SHOW GRANTS FOR 'bookuser'@'%';" 2>/dev/null

echo ""
echo "   Testing bookuser connection..."
kubectl exec $MYSQL_POD -- mysql -u bookuser -pbookpass -e "SELECT 'SUCCESS' as test; SHOW DATABASES;" 2>/dev/null && echo "   ✓ bookuser can connect"

echo ""
echo "10. Ensuring proper authentication plugin..."
kubectl exec $MYSQL_POD -- mysql -u root -prootpassword -e "
  ALTER USER 'bookuser'@'%' IDENTIFIED WITH mysql_native_password BY 'bookpass';
  GRANT ALL PRIVILEGES ON bookreview.* TO 'bookuser'@'%';
  FLUSH PRIVILEGES;
" 2>/dev/null

echo "    ✓ User authentication updated"

echo ""
echo "11. Final verification..."
kubectl exec $MYSQL_POD -- mysql -u bookuser -pbookpass -e "
  SELECT 'Connection verified' as status;
  USE bookreview;
  SHOW TABLES;
" 2>/dev/null

echo ""
echo "12. Restarting backend pods..."
kubectl rollout restart deployment backend

echo "13. Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Check backend logs:"
echo "  kubectl logs -l app=backend --tail=50 -f"
echo ""
echo "If you still see errors, check:"
echo "  kubectl describe pod -l app=backend"
echo "  kubectl get pods"
