$ts=(Get-Date).ToString('o')

# GitHub Pages API
try {
    $apiResp = Invoke-WebRequest -Uri 'https://api.github.com/repos/mikehub565/ybnbmike/pages' -Headers @{ 'User-Agent'='monitor-script' } -UseBasicParsing -TimeoutSec 30
    $apiStatus = $apiResp.StatusCode
    $apiBody = $apiResp.Content
} catch {
    if ($_.Exception.Response) {
        $resp = $_.Exception.Response
        try { $apiStatus = $resp.StatusCode.value__ } catch { $apiStatus = 'error' }
        try { $sr = New-Object System.IO.StreamReader($resp.GetResponseStream()); $apiBody = $sr.ReadToEnd() } catch { $apiBody = $null }
    } else { $apiStatus = 'error'; $apiBody = $_.Exception.Message }
}

# HTTP/HTTPS fetch
function Get-HeadInfo($url) {
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30 -MaximumRedirection 0
        return @{ status = $r.StatusCode; final = $r.BaseResponse.ResponseUri.AbsoluteUri }
    } catch {
        if ($_.Exception.Response) {
            $resp = $_.Exception.Response
            $code = try { $resp.StatusCode.value__ } catch { 'error' }
            $final = try { $resp.ResponseUri.AbsoluteUri } catch { $null }
            return @{ status = $code; final = $final }
        } else { return @{ status = 'error'; final = $null } }
    }
}

$httpsInfo = Get-HeadInfo 'https://ynbmike.me'
$httpInfo = Get-HeadInfo 'http://ynbmike.me'
$httpRedirectsToHttps = $false
if ($httpInfo.final -and $httpInfo.final.StartsWith('https://')) { $httpRedirectsToHttps = $true }

# DNS via dns.google
$dnsA = try { Invoke-RestMethod -Uri 'https://dns.google/resolve?name=ynbmike.me&type=A' -TimeoutSec 30 } catch { $null }
$dnsCname = try { Invoke-RestMethod -Uri 'https://dns.google/resolve?name=www.ynbmike.me&type=CNAME' -TimeoutSec 30 } catch { $null }

$result = [PSCustomObject]@{
    timestamp = $ts
    github_api = @{ status = $apiStatus; body = if ($apiBody) { try { $b = $apiBody | ConvertFrom-Json -ErrorAction SilentlyContinue; if ($b) { $b } else { $apiBody } } catch { $apiBody } } else { $null } }
    https = @{ status = $httpsInfo.status; final = $httpsInfo.final }
    http = @{ status = $httpInfo.status; final = $httpInfo.final; redirects_to_https = $httpRedirectsToHttps }
    dns = @{ a = $dnsA; cname = $dnsCname }
}

$result | ConvertTo-Json -Depth 10
