[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$tests = Get-Content "tests.json" -Encoding UTF8 | ConvertFrom-Json

$total = $tests.tests.Count
$passed = 0
$failed = 0

foreach ($test in $tests.tests) {
    Write-Host "[$($test.id)] $($test.description)"
    Write-Host "  message: $($test.input.message)"
    Write-Host "  resident_notes: $($test.input.resident_notes)"
    
    try {
        $body = $test.input | ConvertTo-Json -Compress -Depth 10
        $webResponse = Invoke-WebRequest `
            -Uri "http://localhost:5678/webhook/jkh-priority" `
            -Method Post `
            -ContentType "application/json; charset=utf-8" `
            -Body $body `
            -TimeoutSec 30 `
            -ErrorAction Stop
        
        $responseText = [System.Text.Encoding]::UTF8.GetString($webResponse.RawContentStream.ToArray())
        $response = $responseText | ConvertFrom-Json
        
        $priority = $response.priority -replace '[^\d]', ''
        $explanation = $response.explanation
        
        Write-Host "priority: $priority"
        Write-Host "explanation: $explanation"
        
        $passed++
    }
    catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -like "*400*") {
            Write-Host "rejected: meaningless request"
            $passed++
        }
        elseif ($errorMsg -like "*404*") {
            Write-Host "error 404: webhook not found (check if workflow is activated)"
            $failed++
        }
        else {
            Write-Host "error: $errorMsg"
            $failed++
        }
    }
    
    Start-Sleep -Milliseconds 500
    Write-Host ""
}

Write-Host "$passed/$total tests passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })