# Starts the full Yugastore stack (Eureka, microservices, react-ui) on Windows.
# Assumes each module has already been built (target\*.jar exists) and that
# YugabyteDB is already running (see the setup-local skill).
# Run from PowerShell: .\start-app.ps1

$ErrorActionPreference = "Continue"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$LogDir = Join-Path $RepoRoot "logs"
$PidDir = Join-Path $RepoRoot ".run"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $PidDir | Out-Null

$Eureka = "eureka-server-local"
$CoreServices = @("api-gateway-microservice", "products-microservice", "checkout-microservice", "cart-microservice")
$Ui = "react-ui"

function Start-Jar {
    param([string]$Module)

    $Dir = Join-Path $RepoRoot $Module
    $Jar = Get-ChildItem -Path (Join-Path $Dir "target") -Filter "$Module-*.jar" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike "*.original" } | Select-Object -First 1

    if (-not $Jar) {
        Write-Warning "Skipping ${Module}: no jar found in ${Dir}\target. Build it first."
        return
    }

    Write-Host "Starting $Module ($($Jar.FullName))"
    $LogFile = Join-Path $LogDir "$Module.log"
    $proc = Start-Process -FilePath "java" -ArgumentList "-jar", "`"$($Jar.FullName)`"" `
        -WorkingDirectory $Dir -RedirectStandardOutput $LogFile -RedirectStandardError "$LogFile.err" `
        -PassThru -WindowStyle Hidden
    $proc.Id | Out-File -FilePath (Join-Path $PidDir "$Module.pid")
}

function Wait-ForLog {
    param([string]$Module, [string]$Pattern, [int]$TimeoutSec = 60)

    $LogFile = Join-Path $LogDir "$Module.log"
    Write-Host "Waiting for $Module to be ready..."
    for ($i = 0; $i -lt $TimeoutSec; $i++) {
        if ((Test-Path $LogFile) -and (Select-String -Path $LogFile -Pattern $Pattern -Quiet -ErrorAction SilentlyContinue)) {
            Write-Host "$Module is up."
            return
        }
        Start-Sleep -Seconds 1
    }
    Write-Warning "$Module did not report readiness within ${TimeoutSec}s; check $LogFile"
}

# Spring Boot logs "Started <MainClass> in N.NNN seconds" on every module
# regardless of class name, so this pattern works generically for all of them.
$ReadyPattern = "Started [A-Za-z0-9_]+ in [0-9.]+ seconds"

Start-Jar -Module $Eureka
Wait-ForLog -Module $Eureka -Pattern $ReadyPattern

foreach ($svc in $CoreServices) {
    Start-Jar -Module $svc
}
Write-Host "Waiting for microservices to register with Eureka..."
Start-Sleep -Seconds 15

Start-Jar -Module $Ui
Wait-ForLog -Module $Ui -Pattern $ReadyPattern

Write-Host ""
Write-Host "All services launched. Logs: $LogDir  PIDs: $PidDir"
Write-Host "Eureka dashboard: http://localhost:8761/eureka/apps"
Write-Host "App entry point (gateway): http://localhost:8081"
Write-Host "React UI (if served standalone): http://localhost:8080"
Write-Host "Use scripts\stop-app.ps1 to stop everything."
