Add-Type -AssemblyName System.Drawing
$src = "WhatsApp Image 2025-01-06 at 17.34.14_d49c606e.jpg"
if(-not (Test-Path $src)){
    Write-Error "Source image not found: $src"
    exit 1
}
$img = [System.Drawing.Image]::FromFile($src)
function Save-Png([int]$w,[int]$h,[string]$out){
    $bmp = New-Object System.Drawing.Bitmap $w,$h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($img,0,0,$w,$h)
    $g.Dispose()
    $bmp.Save($out,[System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Saved $out"
}
Save-Png 32 32 "favicon-32x32.png"
Save-Png 16 16 "favicon-16x16.png"
Save-Png 180 180 "apple-touch-icon.png"
$img.Dispose()
