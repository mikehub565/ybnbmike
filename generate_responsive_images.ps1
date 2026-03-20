Add-Type -AssemblyName System.Drawing
$images = @(
    @{src='WhatsApp Image 2025-01-06 at 17.34.14_d49c606e.jpg'; name='portrait'},
    @{src='portfolio3.jpg'; name='portfolio3'},
    @{src='portfolio4.jpg'; name='portfolio4'},
    @{src='portfolio5.jpg'; name='portfolio5'}
)
function Resize-Image($inPath,$outPath,$maxWidth){
    $img = [System.Drawing.Image]::FromFile($inPath)
    $ratio = $img.Height / $img.Width
    $w = [int]$maxWidth
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
foreach($it in $images){
    $src = $it.src
    if(-not (Test-Path $src)){
        Write-Host "Skipping missing $src"
        continue
    }
    Resize-Image $src "${($it.name)}_1200.jpg" 1200
    Resize-Image $src "${($it.name)}_800.jpg" 800
    Resize-Image $src "${($it.name)}_400.jpg" 400
}
Write-Host "Done"
