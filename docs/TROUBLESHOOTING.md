# Troubleshooting Guide

## Database Access Denied Error

### Problem
```
AccessDeniedError [SequelizeAccessDeniedError]: Access denied for user 'bookuser'@'<IP>' (using password: YES)
```

### Root Cause
The MySQL user 'bookuser' was not properly created or granted permissions to connect from pod IP addresses within the Kubernetes cluster.

### Solution Applied

1. **Updated MySQL Deployment** ([`k8s/mysql-deployment.yml`](../k8s/mysql-deployment.yml))
   - Added environment variables to automatically create the database and user:
     - `MYSQL_DATABASE=bookreview`
     - `MYSQL_USER=bookuser`
     - `MYSQL_PASSWORD=bookpass`
   - These environment variables ensure the user is created when the MySQL container starts

2. **Updated MySQL Init ConfigMap** ([`k8s/mysql-init-configmap.yml`](../k8s/mysql-init-configmap.yml))
   - Modified the init script to grant privileges to the auto-created user
   - Added `mysql_native_password` authentication method for compatibility
   - Ensures the user can connect from any host (`'bookuser'@'%'`)

### How to Apply the Fix

Run the redeployment script:
```bash
./redeploy-mysql.sh
```

Or manually apply the changes:
```bash
# Delete existing MySQL resources
kubectl delete deployment mysql
kubectl delete configmap mysql-init

# Apply updated configurations
kubectl apply -f k8s/mysql-init-configmap.yml
kubectl apply -f k8s/mysql-deployment.yml

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# Restart backend to reconnect
kubectl rollout restart deployment backend
```

### Verification

1. **Check MySQL pod is running:**
   ```bash
   kubectl get pods -l app=mysql
   ```

2. **Check backend pods are running:**
   ```bash
   kubectl get pods -l app=backend
   ```

3. **Check backend logs for successful database connection:**
   ```bash
   kubectl logs -l app=backend --tail=50
   ```
   You should see "Database initialized successfully" instead of access denied errors.

4. **Test database connection from within MySQL pod:**
   ```bash
   kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- \
     mysql -u bookuser -pbookpass -e "SHOW DATABASES;"
   ```
   You should see the `bookreview` database listed.

### Common Issues

#### Issue: MySQL pod keeps restarting
**Solution:** Check MySQL logs:
```bash
kubectl logs -l app=mysql --tail=100
```

#### Issue: Backend still can't connect after redeployment
**Solution:** 
1. Verify MySQL service is accessible:
   ```bash
   kubectl get svc mysql
   ```
2. Test DNS resolution from backend pod:
   ```bash
   kubectl exec -it $(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}') -- \
     nslookup mysql
   ```

#### Issue: User permissions still not working
**Solution:** Connect to MySQL and manually verify/fix permissions:
```bash
# Connect to MySQL pod
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -u root -prootpassword

# Run these commands in MySQL:
GRANT ALL PRIVILEGES ON bookreview.* TO 'bookuser'@'%';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user WHERE user='bookuser';
```

### Prevention

To prevent this issue in the future:
1. Always use MySQL environment variables (`MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`) for initial setup
2. Ensure init scripts run after the container is fully started
3. Use `'%'` wildcard for host in user grants to allow pod-to-pod communication
4. Test database connectivity before deploying dependent services

### Related Files
- [`k8s/mysql-deployment.yml`](../k8s/mysql-deployment.yml) - MySQL deployment configuration
- [`k8s/mysql-init-configmap.yml`](../k8s/mysql-init-configmap.yml) - Database initialization script
- [`k8s/backend-deployment.yml`](../k8s/backend-deployment.yml) - Backend configuration with DB credentials
- [`redeploy-mysql.sh`](../redeploy-mysql.sh) - Automated redeployment script
