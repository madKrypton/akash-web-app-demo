#!/bin/bash
# Kubernetes Deployment Script for DevOps App (Linux/Mac)
# Usage: ./deploy-k8s.sh

echo "=================================="
echo "DevOps App Kubernetes Deployment"
echo "=================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
    exit 1
fi

echo "✓ kubectl found"

# Build Docker images
echo ""
echo "Step 1: Building Docker images..."
echo "Building backend image..."
cd backend
docker build -t akash-backend:latest .
if [ $? -ne 0 ]; then
    echo "ERROR: Backend image build failed"
    exit 1
fi
echo "✓ Backend image built"

echo "Building frontend image..."
cd ../frontend
docker build -t akash-frontend:latest .
if [ $? -ne 0 ]; then
    echo "ERROR: Frontend image build failed"
    exit 1
fi
echo "✓ Frontend image built"

cd ..

# Detect cluster type
echo ""
echo "Step 2: Detecting Kubernetes cluster..."
context=$(kubectl config current-context 2>/dev/null)

if [[ $context == *"minikube"* ]]; then
    echo "Detected Minikube cluster"
    echo "Loading images to Minikube..."
    minikube image load akash-backend:latest
    minikube image load akash-frontend:latest
    echo "✓ Images loaded to Minikube"
elif [[ $context == *"kind"* ]]; then
    echo "Detected Kind cluster"
    echo "Loading images to Kind..."
    kind load docker-image akash-backend:latest
    kind load docker-image akash-frontend:latest
    echo "✓ Images loaded to Kind"
else
    echo "Detected cloud or remote cluster: $context"
    echo "Note: Make sure images are pushed to a registry if needed"
fi

# Deploy to Kubernetes
echo ""
echo "Step 3: Deploying to Kubernetes..."

echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo "Creating ConfigMaps and Secrets..."
kubectl apply -f k8s/postgres-configmap.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/backend-configmap.yaml

echo "Creating PVC for PostgreSQL..."
kubectl apply -f k8s/postgres-pvc.yaml

echo "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres-deployment.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s
if [ $? -ne 0 ]; then
    echo "WARNING: PostgreSQL pod not ready in time"
else
    echo "✓ PostgreSQL is ready"
fi

echo "Deploying Backend..."
kubectl apply -f k8s/backend-deployment.yaml

echo "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n devops-app --timeout=120s
if [ $? -ne 0 ]; then
    echo "WARNING: Backend pods not ready in time"
else
    echo "✓ Backend is ready"
fi

echo "Deploying Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml

echo "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n devops-app --timeout=120s
if [ $? -ne 0 ]; then
    echo "WARNING: Frontend pods not ready in time"
else
    echo "✓ Frontend is ready"
fi

# Display status
echo ""
echo "=================================="
echo "Deployment Status"
echo "=================================="

echo ""
echo "Pods:"
kubectl get pods -n devops-app

echo ""
echo "Services:"
kubectl get services -n devops-app

echo ""
echo "Deployments:"
kubectl get deployments -n devops-app

# Access instructions
echo ""
echo "=================================="
echo "Access Application"
echo "=================================="

if [[ $context == *"minikube"* ]]; then
    echo ""
    echo "To access the application, run:"
    echo "  minikube service frontend-service -n devops-app"
else
    echo ""
    echo "To access the application via port-forward:"
    echo "  kubectl port-forward service/frontend-service 3000:80 -n devops-app"
    echo ""
    echo "Then visit: http://localhost:3000"
fi

echo ""
echo "To view logs:"
echo "  kubectl logs -f deployment/backend -n devops-app"
echo "  kubectl logs -f deployment/frontend -n devops-app"
echo "  kubectl logs -f deployment/postgres -n devops-app"

echo ""
echo "✓ Deployment complete!"
