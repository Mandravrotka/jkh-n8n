param(
    [string]$ContainerName = "n8n",
    [string]$WorkflowFile = "..\workflow\jkh-priority-workflow.json"
)

if (-not (Test-Path $WorkflowFile)) {
    Write-Host "Error: Workflow file not found" -ForegroundColor Red
    exit 1
}

docker cp $WorkflowFile ${ContainerName}:/tmp/import-workflow.json
if ($LASTEXITCODE -ne 0) { exit 1 }

docker exec $ContainerName n8n import:workflow --input /tmp/import-workflow.json
if ($LASTEXITCODE -ne 0) { exit 1 }