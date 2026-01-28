# ===============================
# Auto-elevación a Administrador
# ===============================
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# ===============================
# Nombre de la tarea
# ===============================
$TaskName = "Daily System Restore Point"

# ===============================
# Acción: Crear punto de restauración
# ===============================
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"Checkpoint-Computer -Description 'DailyRestorePoint' -RestorePointType 'MODIFY_SETTINGS'`""

# ===============================
# Trigger: Diario a las 12:00
# ===============================
$Trigger = New-ScheduledTaskTrigger -Daily -At 12:00

# ===============================
# Ejecutar con privilegios elevados
# ===============================
$Principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# ===============================
# Configuración adicional
# ===============================
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

# ===============================
# Registrar la tarea
# ===============================
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Force

Write-Host "La tarea '$TaskName' fue creada correctamente."
