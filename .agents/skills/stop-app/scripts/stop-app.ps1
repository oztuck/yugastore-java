# Stops the Yugastore stack started by start-app.ps1.
# Run from PowerShell: .\stop-app.ps1

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$PidDir = Join-Path $RepoRoot ".run"

if (-not (Test-Path $PidDir)) {
    Write-Host "No PID directory found at $PidDir; nothing to stop."
    exit 0
}

Get-ChildItem -Path $PidDir -Filter "*.pid" | ForEach-Object {
    $Module = $_.BaseName
    $ProcId = Get-Content $_.FullName
    $Proc = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
    if ($Proc) {
        Write-Host "Stopping $Module (pid $ProcId)"
        Stop-Process -Id $ProcId -Force
    } else {
        Write-Host "$Module (pid $ProcId) already stopped"
    }
    Remove-Item $_.FullName -Force
}

Write-Host "Done."
