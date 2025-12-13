# We will Check our deployment and services using following Commands.. 

**To check frontend service:**
```
kubectl get svc frontend
```
 **We will get output like this:**
 ```
 EXTERNAL-IP: a1b2c3d4.elb.amazonaws.com
```

# Now we will deploy to KOPS cluster using following commands:

**Deploy Frontend, Backend and MySql:**
```
kubectl apply -f mysql/
kubectl apply -f backend/
kubectl apply -f frontend/
```
**To Verify:**
```
kubectl get pods
kubectl get svc
```