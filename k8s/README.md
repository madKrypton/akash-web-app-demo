# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the DevOps Authentication Application.

## 📁 Manifest Files

- `namespace.yaml` - Creates the `devops-app` namespace
- `postgres-configmap.yaml` - PostgreSQL configuration
- `postgres-secret.yaml` - PostgreSQL and JWT secrets
- `postgres-pvc.yaml` - Persistent volume claim for PostgreSQL data
- `postgres-deployment.yaml` - PostgreSQL deployment and service
- `backend-configmap.yaml` - Backend API configuration
- `backend-deployment.yaml` - Backend API deployment and service
- `frontend-deployment.yaml` - Frontend deployment and service
- `ingress.yaml` - Ingress configuration (optional)

## 🚀 Deployment Steps

### Prerequisites

1. **Kubernetes cluster** (minikube, kind, GKE, EKS, AKS, etc.)
2. **kubectl** installed and configured
3. **Docker images** built for backend and frontend

### Step 1: Build Docker Images

```powershell
# Build backend image
cd backend
docker build -t akash-backend:latest .

# Build frontend image
cd ../frontend
docker build -t akash-frontend:latest .

cd ..
```

### Step 2: Load Images (for local clusters like minikube/kind)

If using **minikube**:
```powershell
minikube image load akash-backend:latest
minikube image load akash-frontend:latest
```

If using **kind**:
```powershell
kind load docker-image akash-backend:latest
kind load docker-image akash-frontend:latest
```

### Step 3: Deploy to Kubernetes

Deploy all resources in order:

```powershell
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create ConfigMaps and Secrets
kubectl apply -f k8s/postgres-configmap.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/backend-configmap.yaml

# Create PVC for PostgreSQL
kubectl apply -f k8s/postgres-pvc.yaml

# Deploy PostgreSQL
kubectl apply -f k8s/postgres-deployment.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s

# Deploy Backend
kubectl apply -f k8s/backend-deployment.yaml

# Wait for Backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n devops-app --timeout=120s

# Deploy Frontend
kubectl apply -f k8s/frontend-deployment.yaml

# Optional: Apply Ingress (if you have ingress controller)
kubectl apply -f k8s/ingress.yaml
```

### Quick Deploy (All at Once)

```powershell
kubectl apply -f k8s/
```

## 🔍 Verify Deployment

Check all resources:

```powershell
# Check all pods
kubectl get pods -n devops-app

# Check services
kubectl get services -n devops-app

# Check deployments
kubectl get deployments -n devops-app

# Check PVC
kubectl get pvc -n devops-app

# View logs
kubectl logs -f deployment/backend -n devops-app
kubectl logs -f deployment/frontend -n devops-app
kubectl logs -f deployment/postgres -n devops-app
```

## 🌐 Access the Application

### Option 1: Using LoadBalancer (Cloud environments)

```powershell
kubectl get service frontend-service -n devops-app
```

Access via the external IP shown.

### Option 2: Using Port Forward (Local development)

```powershell
# Forward frontend
kubectl port-forward service/frontend-service 3000:80 -n devops-app

# In another terminal, forward backend
kubectl port-forward service/backend-service 5000:5000 -n devops-app
```

Access at: http://localhost:3000

### Option 3: Using Ingress

If you have an ingress controller installed:

```powershell
kubectl get ingress -n devops-app
```

Add to your hosts file (Windows: `C:\Windows\System32\drivers\etc\hosts`):
```
<INGRESS-IP> devops-app.local
```

Access at: http://devops-app.local

### Option 4: Using Minikube Service

If using minikube:

```powershell
minikube service frontend-service -n devops-app
```

## 🔐 Update Secrets

**Important**: Change the secrets before production deployment!

Generate base64 encoded values:

```powershell
# For PostgreSQL password
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("your_new_password"))

# For JWT secret
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("your_new_jwt_secret"))
```

Update `postgres-secret.yaml` with new values.

## 📊 Monitoring

View resource usage:

```powershell
# Pod resource usage
kubectl top pods -n devops-app

# Node resource usage
kubectl top nodes
```

## 🔄 Update Deployment

After code changes:

```powershell
# Rebuild images
docker build -t akash-backend:latest ./backend
docker build -t akash-frontend:latest ./frontend

# Load to cluster (if local)
minikube image load akash-backend:latest
minikube image load akash-frontend:latest

# Restart deployments
kubectl rollout restart deployment/backend -n devops-app
kubectl rollout restart deployment/frontend -n devops-app

# Check rollout status
kubectl rollout status deployment/backend -n devops-app
kubectl rollout status deployment/frontend -n devops-app
```

## 🧹 Cleanup

Remove all resources:

```powershell
# Delete all resources in namespace
kubectl delete -f k8s/

# Or delete the entire namespace
kubectl delete namespace devops-app
```

## 📈 Scaling

Scale deployments:

```powershell
# Scale backend
kubectl scale deployment backend --replicas=3 -n devops-app

# Scale frontend
kubectl scale deployment frontend --replicas=3 -n devops-app

# Verify
kubectl get deployments -n devops-app
```

## 🐛 Troubleshooting

### Pods not starting

```powershell
kubectl describe pod <pod-name> -n devops-app
kubectl logs <pod-name> -n devops-app
```

### Database connection issues

```powershell
# Check if PostgreSQL is ready
kubectl exec -it deployment/postgres -n devops-app -- psql -U postgres -c "\l"

# Test connection from backend
kubectl exec -it deployment/backend -n devops-app -- env | grep DB
```

### Image pull errors

If using local images, ensure:
- Images are built with correct tags
- Images are loaded into the cluster (minikube/kind)
- `imagePullPolicy: IfNotPresent` is set

### Check backend health

```powershell
kubectl exec -it deployment/backend -n devops-app -- wget -qO- http://localhost:5000/api/health
```

## 🎯 Production Considerations

1. **Secrets Management**: Use external secret management (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault)
2. **Image Registry**: Push images to a container registry (Docker Hub, GCR, ECR, ACR)
3. **Persistent Storage**: Use appropriate storage class for your cloud provider
4. **Ingress Controller**: Install and configure (nginx-ingress, traefik)
5. **TLS/HTTPS**: Configure cert-manager for automatic certificate management
6. **Monitoring**: Set up Prometheus and Grafana
7. **Logging**: Configure centralized logging (ELK, Loki)
8. **Resource Limits**: Adjust CPU/Memory based on load testing
9. **Backup**: Implement database backup strategy
10. **High Availability**: Use multiple replicas and pod anti-affinity

## 📝 Configuration Notes

### Resource Requests and Limits

Current configuration:
- **PostgreSQL**: 256Mi-512Mi memory, 250m-500m CPU
- **Backend**: 256Mi-512Mi memory, 250m-500m CPU (2 replicas)
- **Frontend**: 128Mi-256Mi memory, 100m-200m CPU (2 replicas)

Adjust based on your cluster capacity and application needs.

### Health Checks

- **Liveness probes**: Restart unhealthy containers
- **Readiness probes**: Remove unhealthy pods from service load balancing

### Storage

Default PVC requests 5Gi storage. Modify based on expected data size.

---

**Need help?** Check the logs or describe the pods for more information!
