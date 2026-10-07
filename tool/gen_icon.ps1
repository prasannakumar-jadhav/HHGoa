Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Gradient background
$c1 = [System.Drawing.Color]::FromArgb(255, 26, 35, 126)
$c2 = [System.Drawing.Color]::FromArgb(255, 92, 107, 192)
$pt1 = [System.Drawing.Point]::new(0, 0)
$pt2 = [System.Drawing.Point]::new($size, $size)
$gb  = New-Object System.Drawing.Drawing2D.LinearGradientBrush($pt1, $pt2, $c1, $c2)
$g.FillRectangle($gb, 0, 0, $size, $size)
$gb.Dispose()

# Mic white outer shape
$white = [System.Drawing.Brushes]::White
$g.FillEllipse($white, 432, 230, 160, 160)
$g.FillRectangle($white, 432, 310, 160, 110)
$g.FillEllipse($white, 432, 340, 160, 160)

# Mic cyan inner
$cc = [System.Drawing.Color]::FromArgb(230, 0, 172, 193)
$cb = New-Object System.Drawing.SolidBrush($cc)
$g.FillEllipse($cb, 452, 250, 120, 120)
$g.FillRectangle($cb, 452, 310, 120, 100)
$g.FillEllipse($cb, 452, 360, 120, 120)
$cb.Dispose()

# Mic stand
$sw = [System.Drawing.Color]::White
$sp = New-Object System.Drawing.Pen($sw, 28)
$sp.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$sp.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawArc($sp, 360, 490, 304, 320, 180, 180)
$g.DrawLine($sp, 512, 650, 512, 740)
$g.DrawLine($sp, 400, 740, 624, 740)
$sp.Dispose()

# Sound wave bars (cyan)
$wc1 = [System.Drawing.Color]::FromArgb(200, 0, 172, 193)
$wb  = New-Object System.Drawing.SolidBrush($wc1)
$bars = @(
    @(148,430,28,124), @(194,380,28,224), @(240,412,28,160),
    @(756,430,28,124), @(802,380,28,224), @(848,412,28,160)
)
foreach ($bar in $bars) {
    $g.FillRectangle($wb, $bar[0], $bar[1], $bar[2], $bar[3])
}
$wb.Dispose()

# AI accent dot
$ac = [System.Drawing.Color]::FromArgb(255, 0, 229, 255)
$ab = New-Object System.Drawing.SolidBrush($ac)
$g.FillEllipse($ab, 568, 256, 56, 56)
$ab.Dispose()
$g.FillEllipse($white, 580, 268, 32, 32)

$g.Dispose()

$outDir = "d:\FLUTTER\Hackathon\voxpilot\assets\icons"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$outPath = "$outDir\voxpilot_logo_icon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Generated: $outPath"
