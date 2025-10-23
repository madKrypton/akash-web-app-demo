# Kubernetes Cleanup Script
# Usage: .\cleanup-k8s.ps1

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "DevOps App Kubernetes Cleanup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "This will delete all resources in the 'devops-app' namespace. Continue? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nDeleting resources..." -ForegroundColor Yellow

# Delete all resources
kubectl delete -f k8s/ --ignore-not-found=true

Write-Host "`nDeleting namespace..." -ForegroundColor Yellow
kubectl delete namespace devops-app --ignore-not-found=true

Write-Host "`nWaiting for namespace to be deleted..." -ForegroundColor Yellow
$timeout = 60
$elapsed = 0
while ((kubectl get namespace devops-app 2>$null) -and ($elapsed -lt $timeout)) {
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Host "." -NoNewline
}
Write-Host ""

$namespaceCheck = kubectl get namespace devops-app 2>$null
if ($namespaceCheck) {
    Write-Host "WARNING: Namespace still exists after timeout" -ForegroundColor Yellow
} else {
    Write-Host "✓ Cleanup complete!" -ForegroundColor Green
}

Write-Host "`nResources removed:" -ForegroundColor Green
Write-Host "  • Namespace: devops-app" -ForegroundColor White
Write-Host "  • PostgreSQL pod and PVC" -ForegroundColor White
Write-Host "  • Backend deployment" -ForegroundColor White
Write-Host "  • Frontend deployment" -ForegroundColor White
Write-Host "  • All services and configs" -ForegroundColor White
