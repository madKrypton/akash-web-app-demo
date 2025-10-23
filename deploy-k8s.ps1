# Kubernetes Deployment Script for DevOps App
# Usage: .\deploy-k8s.ps1

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "DevOps App Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✓ kubectl found" -ForegroundColor Green

# Build Docker images
Write-Host "`nStep 1: Building Docker images..." -ForegroundColor Yellow
Write-Host "Building backend image..."
Set-Location backend
docker build -t akash-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Backend image build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backend image built" -ForegroundColor Green

Write-Host "Building frontend image..."
Set-Location ../frontend
docker build -t akash-frontend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Frontend image build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Frontend image built" -ForegroundColor Green

Set-Location ..

# Detect cluster type
Write-Host "`nStep 2: Detecting Kubernetes cluster..." -ForegroundColor Yellow
$context = kubectl config current-context 2>$null

if ($context -match "minikube") {
    Write-Host "Detected Minikube cluster" -ForegroundColor Cyan
    Write-Host "Loading images to Minikube..."
    minikube image load akash-backend:latest
    minikube image load akash-frontend:latest
    Write-Host "✓ Images loaded to Minikube" -ForegroundColor Green
}
elseif ($context -match "kind") {
    Write-Host "Detected Kind cluster" -ForegroundColor Cyan
    Write-Host "Loading images to Kind..."
    kind load docker-image akash-backend:latest
    kind load docker-image akash-frontend:latest
    Write-Host "✓ Images loaded to Kind" -ForegroundColor Green
}
else {
    Write-Host "Detected cloud or remote cluster: $context" -ForegroundColor Cyan
    Write-Host "Note: Make sure images are pushed to a registry if needed" -ForegroundColor Yellow
}

# Deploy to Kubernetes
Write-Host "`nStep 3: Deploying to Kubernetes..." -ForegroundColor Yellow

Write-Host "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

Write-Host "Creating ConfigMaps and Secrets..."
kubectl apply -f k8s/postgres-configmap.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/backend-configmap.yaml

Write-Host "Creating PVC for PostgreSQL..."
kubectl apply -f k8s/postgres-pvc.yaml

Write-Host "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres-deployment.yaml

Write-Host "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: PostgreSQL pod not ready in time" -ForegroundColor Yellow
}
else {
    Write-Host "✓ PostgreSQL is ready" -ForegroundColor Green
}

Write-Host "Deploying Backend..."
kubectl apply -f k8s/backend-deployment.yaml

Write-Host "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n devops-app --timeout=120s
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Backend pods not ready in time" -ForegroundColor Yellow
}
else {
    Write-Host "✓ Backend is ready" -ForegroundColor Green
}

Write-Host "Deploying Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml

Write-Host "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n devops-app --timeout=120s
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Frontend pods not ready in time" -ForegroundColor Yellow
}
else {
    Write-Host "✓ Frontend is ready" -ForegroundColor Green
}

# Display status
Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Deployment Status" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nPods:" -ForegroundColor Yellow
kubectl get pods -n devops-app

Write-Host "`nServices:" -ForegroundColor Yellow
kubectl get services -n devops-app

Write-Host "`nDeployments:" -ForegroundColor Yellow
kubectl get deployments -n devops-app

# Access instructions
Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Access Application" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

if ($context -match "minikube") {
    Write-Host "`nTo access the application, run:" -ForegroundColor Green
    Write-Host "  minikube service frontend-service -n devops-app" -ForegroundColor White
}
else {
    Write-Host "`nTo access the application via port-forward:" -ForegroundColor Green
    Write-Host "  kubectl port-forward service/frontend-service 3000:80 -n devops-app" -ForegroundColor White
    Write-Host "`nThen visit: http://localhost:3000" -ForegroundColor White
}

Write-Host "`nTo view logs:" -ForegroundColor Green
Write-Host "  kubectl logs -f deployment/backend -n devops-app" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/frontend -n devops-app" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/postgres -n devops-app" -ForegroundColor White

Write-Host "`n✓ Deployment complete!" -ForegroundColor Green
