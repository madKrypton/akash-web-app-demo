# Kubernetes Helper Script
# Usage: .\k8s-helper.ps1 [command]

param(
    [Parameter(Mandatory=$false)]
    [string]$Command = "help"
)

$namespace = "devops-app"

function Show-Help {
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "Kubernetes Helper Commands" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\k8s-helper.ps1 [command]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Green
    Write-Host "  status      - Show status of all resources" -ForegroundColor White
    Write-Host "  pods        - List all pods" -ForegroundColor White
    Write-Host "  logs        - Show logs menu" -ForegroundColor White
    Write-Host "  describe    - Describe resources menu" -ForegroundColor White
    Write-Host "  restart     - Restart deployments" -ForegroundColor White
    Write-Host "  scale       - Scale deployments" -ForegroundColor White
    Write-Host "  port-forward - Forward ports to local" -ForegroundColor White
    Write-Host "  exec        - Execute command in pod" -ForegroundColor White
    Write-Host "  top         - Show resource usage" -ForegroundColor White
    Write-Host "  events      - Show recent events" -ForegroundColor White
    Write-Host "  help        - Show this help message" -ForegroundColor White
    Write-Host ""
}

function Show-Status {
    Write-Host "Status of resources in namespace: $namespace" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Pods:" -ForegroundColor Yellow
    kubectl get pods -n $namespace
    
    Write-Host "`nServices:" -ForegroundColor Yellow
    kubectl get services -n $namespace
    
    Write-Host "`nDeployments:" -ForegroundColor Yellow
    kubectl get deployments -n $namespace
    
    Write-Host "`nPVC:" -ForegroundColor Yellow
    kubectl get pvc -n $namespace
}

function Show-Logs {
    Write-Host "Select deployment to view logs:" -ForegroundColor Cyan
    Write-Host "1. Backend" -ForegroundColor White
    Write-Host "2. Frontend" -ForegroundColor White
    Write-Host "3. PostgreSQL" -ForegroundColor White
    Write-Host "4. All (combined)" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-4)"
    
    switch ($choice) {
        "1" { kubectl logs -f deployment/backend -n $namespace }
        "2" { kubectl logs -f deployment/frontend -n $namespace }
        "3" { kubectl logs -f deployment/postgres -n $namespace }
        "4" { 
            Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
            kubectl logs -f deployment/backend -n $namespace --prefix=true &
            kubectl logs -f deployment/frontend -n $namespace --prefix=true &
            kubectl logs -f deployment/postgres -n $namespace --prefix=true
        }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
}

function Describe-Resources {
    Write-Host "Select resource to describe:" -ForegroundColor Cyan
    Write-Host "1. Backend pods" -ForegroundColor White
    Write-Host "2. Frontend pods" -ForegroundColor White
    Write-Host "3. PostgreSQL pods" -ForegroundColor White
    Write-Host "4. All services" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-4)"
    
    switch ($choice) {
        "1" { kubectl describe pods -l app=backend -n $namespace }
        "2" { kubectl describe pods -l app=frontend -n $namespace }
        "3" { kubectl describe pods -l app=postgres -n $namespace }
        "4" { kubectl describe services -n $namespace }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
}

function Restart-Deployments {
    Write-Host "Select deployment to restart:" -ForegroundColor Cyan
    Write-Host "1. Backend" -ForegroundColor White
    Write-Host "2. Frontend" -ForegroundColor White
    Write-Host "3. All" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-3)"
    
    switch ($choice) {
        "1" { 
            kubectl rollout restart deployment/backend -n $namespace
            kubectl rollout status deployment/backend -n $namespace
        }
        "2" { 
            kubectl rollout restart deployment/frontend -n $namespace
            kubectl rollout status deployment/frontend -n $namespace
        }
        "3" { 
            kubectl rollout restart deployment/backend -n $namespace
            kubectl rollout restart deployment/frontend -n $namespace
            Write-Host "Waiting for rollouts to complete..." -ForegroundColor Yellow
            kubectl rollout status deployment/backend -n $namespace
            kubectl rollout status deployment/frontend -n $namespace
        }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
}

function Scale-Deployments {
    Write-Host "Select deployment to scale:" -ForegroundColor Cyan
    Write-Host "1. Backend" -ForegroundColor White
    Write-Host "2. Frontend" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-2)"
    $replicas = Read-Host "Number of replicas"
    
    switch ($choice) {
        "1" { kubectl scale deployment backend --replicas=$replicas -n $namespace }
        "2" { kubectl scale deployment frontend --replicas=$replicas -n $namespace }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
    
    Write-Host "`nCurrent status:" -ForegroundColor Yellow
    kubectl get deployments -n $namespace
}

function Port-Forward {
    Write-Host "Starting port forwarding..." -ForegroundColor Cyan
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Green
    Write-Host "Backend: http://localhost:5000" -ForegroundColor Green
    Write-Host "PostgreSQL: localhost:5432" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    Start-Job -ScriptBlock { kubectl port-forward service/frontend-service 3000:80 -n devops-app }
    Start-Job -ScriptBlock { kubectl port-forward service/backend-service 5000:5000 -n devops-app }
    Start-Job -ScriptBlock { kubectl port-forward service/postgres-service 5432:5432 -n devops-app }
    
    Write-Host "Port forwarding started in background" -ForegroundColor Green
    Write-Host "To stop: Get-Job | Stop-Job; Get-Job | Remove-Job" -ForegroundColor Yellow
}

function Exec-Command {
    Write-Host "Select pod to exec into:" -ForegroundColor Cyan
    Write-Host "1. Backend" -ForegroundColor White
    Write-Host "2. PostgreSQL" -ForegroundColor White
    
    $choice = Read-Host "`nEnter choice (1-2)"
    
    switch ($choice) {
        "1" { kubectl exec -it deployment/backend -n $namespace -- /bin/sh }
        "2" { kubectl exec -it deployment/postgres -n $namespace -- psql -U postgres authdb }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
}

function Show-Top {
    Write-Host "Resource usage:" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Pods:" -ForegroundColor Yellow
    kubectl top pods -n $namespace
    
    Write-Host "`nNodes:" -ForegroundColor Yellow
    kubectl top nodes
}

function Show-Events {
    Write-Host "Recent events in namespace: $namespace" -ForegroundColor Cyan
    kubectl get events -n $namespace --sort-by='.lastTimestamp' | Select-Object -Last 20
}

# Main command handler
switch ($Command.ToLower()) {
    "status" { Show-Status }
    "pods" { kubectl get pods -n $namespace -o wide }
    "logs" { Show-Logs }
    "describe" { Describe-Resources }
    "restart" { Restart-Deployments }
    "scale" { Scale-Deployments }
    "port-forward" { Port-Forward }
    "exec" { Exec-Command }
    "top" { Show-Top }
    "events" { Show-Events }
    "help" { Show-Help }
    default { 
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
    }
}
