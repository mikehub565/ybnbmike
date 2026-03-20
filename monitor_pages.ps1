param(
    [int]$RunCount = 16,
    [int]$IntervalMinutes = 15,
    [string]$LogPath = "monitor_log.jsonl"
)

function Get-HttpHeadersFirstLine {
    param($url)
    try {
        $out = & 'curl.exe' '-s' '-D' '-' '-o' 'NUL' '--max-time' '30' $url
        if (-not $out) { return @{ raw = $null; firstLine = $null } }
        $lines = $out -split "`r?`n"
        $first = $lines | Select-Object -First 1
        return @{ raw = $out; firstLine = $first }
    } catch {
        return @{ raw = $null; firstLine = $null }
    }
}

function Do-Check {
    $timestamp = (Get-Date).ToString('o')

    # GitHub Pages API
    $apiHeadersFile = Join-Path $env:TEMP 'api_pages_headers.txt'
    $apiBodyFile = Join-Path $env:TEMP 'api_pages_body.json'
    & 'curl.exe' '-s' '-D' $apiHeadersFile '-o' $apiBodyFile '-H' 'User-Agent: monitor-script' 'https://api.github.com/repos/mikehub565/ybnbmike/pages'
    $apiStatusLine = if (Test-Path $apiHeadersFile) { Get-Content $apiHeadersFile | Select-Object -First 1 } else { $null }
    $apiStatus = if ($apiStatusLine) { ($apiStatusLine -split ' ')[1] } else { 'error' }
    $apiBody = if (Test-Path $apiBodyFile) { Get-Content $apiBodyFile -Raw } else { $null }
    $apiSummary = $null
    if ($apiBody) {
        try { $apiSummary = $apiBody | ConvertFrom-Json -ErrorAction Stop } catch { $apiSummary = $apiBody }
    }

    # Fetch https and http headers
    $httpsInfo = Get-HttpHeadersFirstLine -url 'https://ynbmike.me'
    $httpInfo = Get-HttpHeadersFirstLine -url 'http://ynbmike.me'

    $httpsStatus = $null; $httpsFirst = $null
    if ($httpsInfo -and $httpsInfo.firstLine) { $parts = $httpsInfo.firstLine -split ' '; if ($parts.Length -ge 2) { $httpsStatus = $parts[1]; $httpsFirst = $httpsInfo.firstLine } }
    $httpStatus = $null; $httpFirst = $null
    if ($httpInfo -and $httpInfo.firstLine) { $parts = $httpInfo.firstLine -split ' '; if ($parts.Length -ge 2) { $httpStatus = $parts[1]; $httpFirst = $httpInfo.firstLine } }

    # Check if http redirects to https by looking for Location header in http raw
    $httpRedirectsToHttps = $false
    if ($httpInfo -and $httpInfo.raw) {
        if ($httpInfo.raw -match "(?mi)^Location:\s*(https://[^\r\n]+)") { $httpRedirectsToHttps = $true }
    }

    # DNS via dns.google
    $dnsA = $null; $dnsCname = $null
    try { $dnsA = (& 'curl.exe' '-s' 'https://dns.google/resolve?name=ynbmike.me&type=A') | ConvertFrom-Json -ErrorAction SilentlyContinue } catch {}
    try { $dnsCname = (& 'curl.exe' '-s' 'https://dns.google/resolve?name=www.ynbmike.me&type=CNAME') | ConvertFrom-Json -ErrorAction SilentlyContinue } catch {}

    $result = [PSCustomObject]@{
        timestamp = $timestamp
        github_api = @{ status = $apiStatus; body_summary = $apiSummary }
        https = @{ status_line = $httpsFirst; status = $httpsStatus }
        http = @{ status_line = $httpFirst; status = $httpStatus; redirects_to_https = $httpRedirectsToHttps }
        dns = @{ a = $dnsA; cname = $dnsCname }
    }

    $json = $result | ConvertTo-Json -Depth 10
    Add-Content -Path $LogPath -Value $json

    return $result
}

# Main loop
$stopEarly = $false
for ($i = 1; $i -le $RunCount; $i++) {
    $res = Do-Check
    if ($res.github_api -and $res.github_api.body_summary) {
        try {
            $body = $res.github_api.body_summary
            if (($body.https_enforced -eq $true) -or ($body.https_certificate) -or ($res.http.redirects_to_https -eq $true)) {
                $stopEarly = $true
            }
        } catch { }
    } elseif ($res.http.redirects_to_https -eq $true) { $stopEarly = $true }

    if ($stopEarly) { break }
    if ($i -lt $RunCount) { Start-Sleep -Seconds ($IntervalMinutes * 60) }
}

# Write summary
$summary = @{ finished = (Get-Date).ToString('o'); run_count = $i; stopped_early = $stopEarly }
Add-Content -Path $LogPath -Value (ConvertTo-Json $summary)

Write-Output "Monitoring finished. Log: $LogPath"
param(
    [int]$RunCount = 16,
    [int]$IntervalMinutes = 15,
    [string]$LogPath = "monitor_log.jsonl"
)

function Get-HttpHeadersFirstLine {
    param($url)
    $cmd = "curl.exe -s -D - -o NUL --max-time 30 '$url'"
    $out = & cmd /c $cmd 2>&1
    if (-not $out) { return @{ status = 'error'; firstLine = $null; headers = $null } }
    $lines = $out -split "`r?`n"
    $first = $lines | Select-Object -First 1
    return @{ raw = $out; firstLine = $first }
}

function Do-Check {
    $timestamp = (Get-Date).ToString('o')

    # GitHub Pages API
    $apiHeadersFile = "$env:TEMP\api_pages_headers.txt"
    $apiBodyFile = "$env:TEMP\api_pages_body.json"
    $apiCmd = "curl.exe -s -D $apiHeadersFile -o $apiBodyFile -H \"User-Agent: monitor-script\" https://api.github.com/repos/mikehub565/ybnbmike/pages"
    cmd /c $apiCmd | Out-Null
    $apiStatusLine = if (Test-Path $apiHeadersFile) { Get-Content $apiHeadersFile | Select-Object -First 1 } else { $null }
    $apiStatus = if ($apiStatusLine) { ($apiStatusLine -split ' ')[1] } else { 'error' }
    $apiBody = if (Test-Path $apiBodyFile) { Get-Content $apiBodyFile -Raw } else { $null }
    $apiSummary = $null
    if ($apiBody) {
        try { $apiJson = $apiBody | ConvertFrom-Json -ErrorAction Stop; $apiSummary = $apiJson | Select-Object -Property * -ExcludeProperty '' } catch { $apiSummary = $apiBody }
    }

    # Fetch https and http
    $httpsInfo = Get-HttpHeadersFirstLine -url 'https://ynbmike.me'
    $httpInfo = Get-HttpHeadersFirstLine -url 'http://ynbmike.me'

    $httpsStatus = $null; $httpsFirst = $null
    if ($httpsInfo -and $httpsInfo.firstLine) { $parts = $httpsInfo.firstLine -split ' '; if ($parts.Length -ge 2) { $httpsStatus = $parts[1]; $httpsFirst = $httpsInfo.firstLine } }
    $httpStatus = $null; $httpFirst = $null
    if ($httpInfo -and $httpInfo.firstLine) { $parts = $httpInfo.firstLine -split ' '; if ($parts.Length -ge 2) { $httpStatus = $parts[1]; $httpFirst = $httpInfo.firstLine } }

    # Check if http redirects to https by looking for Location header in http raw
    $httpRedirectsToHttps = $false
    if ($httpInfo -and $httpInfo.raw) {
        if ($httpInfo.raw -match "(?mi)^Location:\s*(https://[^











































Write-Output "Monitoring finished. Log: $LogPath"Add-Content -Path $LogPath -Value (ConvertTo-Json $summary)$summary = @{ finished = (Get-Date).ToString('o'); run_count = $i; stopped_early = $stopEarly }# Write summary}    if ($i -lt $RunCount) { Start-Sleep -Seconds ($IntervalMinutes * 60) }    if ($stopEarly) { break }    } elseif ($res.http.redirects_to_https -eq $true) { $stopEarly = $true }        } catch { }            }                $stopEarly = $true            if ($body.https_enforced -or $body.https_certificate -or ($res.http.redirects_to_https -eq $true)) {            $body = $res.github_api.body_summary        try {    if ($res.github_api -and $res.github_api.body_summary) {    $res = Do-Checkfor ($i = 1; $i -le $RunCount; $i++) {$stopEarly = $false# Main loop}    return $result    Add-Content -Path $LogPath -Value $json    $json = $result | ConvertTo-Json -Depth 10    }        dns = @{ a = $dnsA; cname = $dnsCname }        http = @{ status_line = $httpFirst; status = $httpStatus; redirects_to_https = $httpRedirectsToHttps }        https = @{ status_line = $httpsFirst; status = $httpsStatus }        github_api = @{ status = $apiStatus; body_summary = $apiSummary }        timestamp = $timestamp    $result = [PSCustomObject]@{    $dnsCname = (curl.exe -s "https://dns.google/resolve?name=www.ynbmike.me&type=CNAME" ) | ConvertFrom-Json -ErrorAction SilentlyContinue    $dnsA = (curl.exe -s "https://dns.google/resolve?name=ynbmike.me&type=A" ) | ConvertFrom-Json -ErrorAction SilentlyContinue    # DNS via dns.google    }\n]+)") { $httpRedirectsToHttps = $true }