param(
    [string]$ContainerName = "n8n",
    [string]$CredentialsFile = "..\credentials\ollama-credentials.json"
)

if (-not (Test-Path $CredentialsFile)) {
    Write-Host "Error: Credentials file not found" -ForegroundColor Red
    exit 1
}

docker cp $CredentialsFile ${ContainerName}:/tmp/import-credentials.json
if ($LASTEXITCODE -ne 0) { exit 1 }

docker exec $ContainerName n8n import:credentials --input /tmp/import-credentials.json
if ($LASTEXITCODE -ne 0) { exit 1 }