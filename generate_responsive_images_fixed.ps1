Add-Type -AssemblyName System.Drawing
$map = @{
    'WhatsApp Image 2025-01-06 at 17.34.14_d49c606e.jpg' = 'portrait'
    'portfolio3.jpg' = 'portfolio3'
    'portfolio4.jpg' = 'portfolio4'
    'portfolio5.jpg' = 'portfolio5'
}
function Resize($in,$outW,$outPath){
    $img = [System.Drawing.Image]::FromFile($in)
    $ratio = $img.Height / $img.Width
    $w = [int]$outW
    $h = [int]([math]::Round($w * $ratio))
    $bmp = New-Object System.Drawing.Bitmap $w,$h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage($img,0,0,$w,$h)
    $g.Dispose()
    $bmp.Save($outPath,[System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp.Dispose()
    $img.Dispose()
    Write-Host "Saved $outPath"
}
foreach($k in $map.Keys){
    $prefix = $map[$k]
    if(-not (Test-Path $k)){
        Write-Host "Source missing: $k"
        continue
    }
    Resize $k 1200 "${prefix}_1200.jpg"
    Resize $k 800 "${prefix}_800.jpg"
    Resize $k 400 "${prefix}_400.jpg"
}
Write-Host "Done fixed resizing"
