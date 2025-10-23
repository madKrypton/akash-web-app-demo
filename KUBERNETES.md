# Kubernetes Deployment Summary

## 📦 What's Included

I've created a complete Kubernetes deployment setup for your DevOps application:

### Kubernetes Manifests (k8s/ directory)

1. **namespace.yaml** - Creates isolated namespace `devops-app`
2. **postgres-configmap.yaml** - PostgreSQL configuration
3. **postgres-secret.yaml** - Secure credentials (passwords, JWT secret)
4. **postgres-pvc.yaml** - 5Gi persistent storage for database
5. **postgres-deployment.yaml** - PostgreSQL pod with health checks
6. **backend-configmap.yaml** - Backend API configuration
7. **backend-deployment.yaml** - Backend API with 2 replicas
8. **frontend-deployment.yaml** - Frontend with 2 replicas
9. **ingress.yaml** - Optional ingress for advanced routing

### Deployment Scripts

1. **deploy-k8s.ps1** - Automated deployment for Windows (PowerShell)
2. **deploy-k8s.sh** - Automated deployment for Linux/Mac (Bash)
3. **cleanup-k8s.ps1** - Clean removal of all resources
4. **k8s-helper.ps1** - Interactive helper for common operations

## 🎯 Key Features

### PostgreSQL Database
- **Persistent Storage**: 5Gi PVC ensures data survives pod restarts
- **Health Checks**: Liveness and readiness probes
- **Resource Limits**: 256Mi-512Mi memory, 250m-500m CPU
- **Internal Service**: Accessible only within cluster

### Backend API
- **High Availability**: 2 replicas with load balancing
- **Auto-restart**: Health checks automatically restart failed pods
- **Secrets Management**: Passwords and JWT stored securely
- **Resource Limits**: 256Mi-512Mi memory, 250m-500m CPU

### Frontend
- **High Availability**: 2 replicas
- **Nginx Serving**: Production-optimized static serving
- **External Access**: LoadBalancer service type
- **Resource Limits**: 128Mi-256Mi memory, 100m-200m CPU

## 🚀 Quick Start

### One-Command Deployment
```powershell
.\deploy-k8s.ps1
```

This will:
1. ✅ Build Docker images
2. ✅ Load images to cluster (minikube/kind)
3. ✅ Create namespace
4. ✅ Deploy PostgreSQL with persistent storage
5. ✅ Deploy backend with 2 replicas
6. ✅ Deploy frontend with 2 replicas
7. ✅ Show deployment status

### Access the Application

**Option 1: Port Forward** (Works on all clusters)
```powershell
kubectl port-forward service/frontend-service 3000:80 -n devops-app
```
Access at: http://localhost:3000

**Option 2: Minikube Service** (Minikube only)
```powershell
minikube service frontend-service -n devops-app
```

**Option 3: LoadBalancer** (Cloud clusters)
```powershell
kubectl get service frontend-service -n devops-app
# Use the EXTERNAL-IP shown
```

## 🛠️ Helper Commands

### Interactive Helper Script
```powershell
.\k8s-helper.ps1 status       # Show all resources
.\k8s-helper.ps1 logs         # View logs
.\k8s-helper.ps1 restart      # Restart deployments
.\k8s-helper.ps1 scale        # Scale replicas
.\k8s-helper.ps1 port-forward # Forward all ports
.\k8s-helper.ps1 help         # Show all commands
```

### Manual Commands
```powershell
# Check status
kubectl get all -n devops-app

# View logs
kubectl logs -f deployment/backend -n devops-app
kubectl logs -f deployment/frontend -n devops-app
kubectl logs -f deployment/postgres -n devops-app

# Scale deployments
kubectl scale deployment backend --replicas=3 -n devops-app
kubectl scale deployment frontend --replicas=3 -n devops-app

# Describe pods
kubectl describe pods -l app=backend -n devops-app

# Execute into pods
kubectl exec -it deployment/backend -n devops-app -- /bin/sh
kubectl exec -it deployment/postgres -n devops-app -- psql -U postgres authdb

# View resource usage
kubectl top pods -n devops-app
kubectl top nodes
```

## 🔐 Security Best Practices

### Before Production

1. **Change Secrets**
   ```powershell
   # Generate new base64 encoded values
   [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("your_secure_password"))
   ```
   Update in `k8s/postgres-secret.yaml`

2. **Use External Secret Management**
   - AWS Secrets Manager
   - Azure Key Vault
   - HashiCorp Vault
   - Kubernetes External Secrets Operator

3. **Enable RBAC**
   - Create service accounts
   - Define role-based access control

4. **Network Policies**
   - Restrict pod-to-pod communication
   - Only allow necessary traffic

## 📊 Monitoring & Troubleshooting

### Common Issues

**Pods not starting**
```powershell
kubectl describe pod <pod-name> -n devops-app
kubectl logs <pod-name> -n devops-app
```

**Image pull errors** (Local clusters)
```powershell
# Rebuild and reload
docker build -t akash-backend:latest ./backend
minikube image load akash-backend:latest
kubectl rollout restart deployment/backend -n devops-app
```

**Database connection issues**
```powershell
# Check PostgreSQL is ready
kubectl get pods -l app=postgres -n devops-app
kubectl logs deployment/postgres -n devops-app

# Test connection from backend
kubectl exec -it deployment/backend -n devops-app -- env | grep DB
```

**Service not accessible**
```powershell
# Check service endpoints
kubectl get endpoints -n devops-app

# Check service details
kubectl describe service frontend-service -n devops-app
```

### View Events
```powershell
kubectl get events -n devops-app --sort-by='.lastTimestamp'
```

## 🎨 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │         Namespace: devops-app                    │   │
│  │                                                   │   │
│  │  ┌──────────────┐      ┌──────────────┐        │   │
│  │  │  Frontend    │      │   Backend    │        │   │
│  │  │  (2 replicas)│◄────►│  (2 replicas)│        │   │
│  │  │  Nginx:80    │      │  Node:5000   │        │   │
│  │  └──────┬───────┘      └──────┬───────┘        │   │
│  │         │                     │                  │   │
│  │         │                     │                  │   │
│  │  ┌──────▼─────────────────────▼───────┐        │   │
│  │  │         Services Layer             │        │   │
│  │  │  • frontend-service (LoadBalancer) │        │   │
│  │  │  • backend-service (ClusterIP)     │        │   │
│  │  │  • postgres-service (ClusterIP)    │        │   │
│  │  └───────────────┬────────────────────┘        │   │
│  │                  │                              │   │
│  │         ┌────────▼──────────┐                  │   │
│  │         │    PostgreSQL     │                  │   │
│  │         │    (1 replica)    │                  │   │
│  │         │    Port: 5432     │                  │   │
│  │         └────────┬──────────┘                  │   │
│  │                  │                              │   │
│  │         ┌────────▼──────────┐                  │   │
│  │         │  Persistent Vol   │                  │   │
│  │         │      (5Gi)        │                  │   │
│  │         └───────────────────┘                  │   │
│  └───────────────────────────────────────────────┘   │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## 🧹 Cleanup

Remove everything:
```powershell
.\cleanup-k8s.ps1
```

Or manually:
```powershell
kubectl delete namespace devops-app
```

## 📈 Scaling & Performance

### Horizontal Scaling
```powershell
# Scale backend to handle more load
kubectl scale deployment backend --replicas=5 -n devops-app

# Scale frontend
kubectl scale deployment frontend --replicas=5 -n devops-app
```

### Vertical Scaling
Edit deployment YAML files and update resource limits:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### Auto-scaling (HPA)
```powershell
# Create horizontal pod autoscaler
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n devops-app
```

## 🌐 Production Checklist

- [ ] Change all secrets and passwords
- [ ] Use external secret management
- [ ] Configure ingress with TLS/HTTPS
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Configure centralized logging (ELK/Loki)
- [ ] Implement backup strategy for PostgreSQL
- [ ] Set resource quotas and limits
- [ ] Configure network policies
- [ ] Set up CI/CD pipeline
- [ ] Enable pod security policies
- [ ] Configure node affinity/anti-affinity
- [ ] Set up disaster recovery plan

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## 🎉 Success!

Your application is now ready to deploy to any Kubernetes cluster:
- ✅ Local development (minikube, kind)
- ✅ Cloud platforms (GKE, EKS, AKS)
- ✅ On-premises clusters

Run `.\deploy-k8s.ps1` and you're good to go! 🚀
