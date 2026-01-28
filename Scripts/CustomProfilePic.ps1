# =====================================================
# Auto-elevación a Administrador
# =====================================================
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Start-Process powershell.exe `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# =====================================================
# Cargar librerías necesarias
# =====================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =====================================================
# Selector de imagen
# =====================================================
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Seleccione la imagen base"
$OpenFileDialog.Filter = "Imágenes (*.png;*.jpg;*.jpeg;*.bmp)|*.png;*.jpg;*.jpeg;*.bmp"
$OpenFileDialog.Multiselect = $false

if ($OpenFileDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "No se seleccionó ninguna imagen. Operación cancelada."
    exit
}

$SourceImagePath = $OpenFileDialog.FileName

# =====================================================
# Directorio destino
# =====================================================
$TargetDir = "C:\ProgramData\Microsoft\User Account Pictures"

if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# =====================================================
# Definición de imágenes requeridas
# =====================================================
$Images = @(
    @{ Name = "user.bmp";     Size = 448; Format = "Bmp" },
    @{ Name = "user.png";     Size = 448; Format = "Png" },
    @{ Name = "user-32.png";  Size = 32;  Format = "Png" },
    @{ Name = "user-40.png";  Size = 40;  Format = "Png" },
    @{ Name = "user-48.png";  Size = 48;  Format = "Png" },
    @{ Name = "user-192.png"; Size = 192; Format = "Png" }
)

# =====================================================
# Función de redimensionado
# =====================================================
function Resize-Image {
    param (
        [System.Drawing.Image]$Image,
        [int]$Width,
        [int]$Height
    )

    $Bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)

    $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $Graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $Graphics.DrawImage($Image, 0, 0, $Width, $Height)

    $Graphics.Dispose()
    return $Bitmap
}

# =====================================================
# Procesamiento de imágenes
# =====================================================
$SourceImage = [System.Drawing.Image]::FromFile($SourceImagePath)

foreach ($Img in $Images) {
    $Resized = Resize-Image -Image $SourceImage -Width $Img.Size -Height $Img.Size
    $OutputPath = Join-Path $TargetDir $Img.Name

    $ImageFormat = [System.Drawing.Imaging.ImageFormat]::$($Img.Format)
    $Resized.Save($OutputPath, $ImageFormat)
    $Resized.Dispose()

    Write-Host "Creado: $OutputPath"
}

$SourceImage.Dispose()

Write-Host "`nTodas las imágenes se han generado y reemplazado correctamente."
