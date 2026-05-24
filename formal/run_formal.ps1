# SymbiYosys formal runner (Windows)
param(
    [ValidateSet("all", "handshake", "slave")]
    [string]$Task = "all"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command sby -ErrorAction SilentlyContinue)) {
    Write-Host "SymbiYosys (sby) not in PATH." -ForegroundColor Yellow
    Write-Host "Install OSS CAD Suite: https://github.com/YosysHQ/oss-cad-suite/releases" -ForegroundColor Yellow
    Write-Host "Then add oss-cad-suite\bin to PATH." -ForegroundColor Yellow
    exit 1
}

switch ($Task) {
    "all"        { make all }
    "handshake"  { make handshake }
    "slave"      { make slave }
}

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Formal $Task finished." -ForegroundColor Green
