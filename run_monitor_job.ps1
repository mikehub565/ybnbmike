$max = 16
$interval = 15 # minutes
$log = Join-Path (Get-Location) 'monitor_log.jsonl'
for ($i = 1; $i -le $max; $i++) {
    try {
        $json = & '.\quick_check.ps1'
    } catch {
        $json = "{\"timestamp\": \"$(Get-Date -Format o)\", \"error\": \"exception running quick_check\" }"
    }
    Add-Content -Path $log -Value $json
    if ($json -match '"redirects_to_https"\s*:\s*true' -or $json -match 'https_enforced') { break }
    if ($i -lt $max) { Start-Sleep -Seconds ($interval * 60) }
}
Add-Content -Path $log -Value (ConvertTo-Json @{ finished=(Get-Date).ToString('o'); run_count=$i })
