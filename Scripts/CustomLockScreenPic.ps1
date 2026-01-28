# ===============================
# Auto-elevación a Administrador
# ===============================
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Start-Process powershell.exe `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# ===============================
# Selector de imagen
# ===============================
Add-Type -AssemblyName System.Windows.Forms

$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Seleccione la imagen para la pantalla de bloqueo"
$OpenFileDialog.Filter = "Imágenes (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp"
$OpenFileDialog.Multiselect = $false

if ($OpenFileDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "No se seleccionó ninguna imagen. Script cancelado."
    exit
}

$ImagePath = $OpenFileDialog.FileName

# ===============================
# Registro: Lock Screen
# ===============================
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

if (!(Test-Path -Path $Key)) {
    New-Item -Path $Key -Force | Out-Null
}

Set-ItemProperty -Path $Key -Name LockScreenImagePath -Value $ImagePath
Set-ItemProperty -Path $Key -Name LockScreenImageUrl -Value $ImagePath
Set-ItemProperty -Path $Key -Name LockScreenImageStatus -Value 1 -Type DWord

Write-Host "Imagen de pantalla de bloqueo configurada correctamente:"
Write-Host $ImagePath
