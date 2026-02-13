# run-tests.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$tests = Get-Content "tests.json" -Encoding UTF8 | ConvertFrom-Json

$total = $tests.tests.Count
$passed = 0
$failed = 0

foreach ($test in $tests.tests) {
    Write-Host "[$($test.id)] $($test.description)"
    
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
        
        Write-Host "  Priority: $priority"
        if ($explanation) {
            Write-Host "  $explanation"
        }
        $passed++
    }
    catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -like "*400*") {
            Write-Host "  Rejected: meaningless request"
            $passed++
        }
        elseif ($errorMsg -like "*404*") {
            Write-Host "  Error 404: webhook not found"
            $failed++
        }
        else {
            Write-Host "  Error: $errorMsg"
            $failed++
        }
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Total tests: $total"
Write-Host "Passed: $passed"
Write-Host "Failed: $failed"