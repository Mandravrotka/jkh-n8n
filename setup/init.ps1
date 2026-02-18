param([string]$ContainerName = "n8n")

Write-Host "Initializing..." -ForegroundColor Cyan

docker --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "..\.env")) {
   Write-Host "Error: No .env" -ForegroundColor Red
   exit 1
}

Set-Location ".."
docker-compose up -d

Set-Location "setup"
.\import-credentials.ps1 -ContainerName $ContainerName
.\import-workflow.ps1 -ContainerName $ContainerName
Set-Location ".."

Write-Host "" -ForegroundColor Green
Write-Host "Done! Open http://localhost:5678 and activate workflow" -ForegroundColor Green