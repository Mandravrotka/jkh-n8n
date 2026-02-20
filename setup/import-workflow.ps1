param(
    [string]$ContainerName = "n8n",
    [string]$WorkflowFile = "..\workflow\jkh-priority-workflow.json",
    [switch]$All
)

    $workflowFiles = Get-ChildItem "..\workflow\*.json"
    foreach ($file in $workflowFiles) {
        if (-not (Test-Path $file.FullName)) {
            Write-Host "Error: Workflow file not found: $($file.FullName)" -ForegroundColor Red
            continue
        }

        docker cp $file.FullName ${ContainerName}:/tmp/import-workflow.json
        if ($LASTEXITCODE -ne 0) { continue }

        docker exec $ContainerName n8n import:workflow --input /tmp/import-workflow.json
        if ($LASTEXITCODE -ne 0) { continue }
    }
