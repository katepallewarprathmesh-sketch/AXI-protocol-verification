# AXI UVM regression script (Questa)
$ErrorActionPreference = "Stop"
$SimDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SimDir

$Tests = @(
    "axi_smoke_test",
    "axi_burst_test",
    "axi_rand_test"
)

if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path "logs" | Out-Null }

$Pass = 0
$Fail = 0
$Results = @()

foreach ($t in $Tests) {
    Write-Host "========== Running $t ==========" -ForegroundColor Cyan
    $logFile = "logs\regression_$t.log"
    $env:TEST = $t
    & make run TEST=$t SEED=1 2>&1 | Tee-Object -FilePath $logFile
    $log = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
    if ($log -match "UVM_ERROR\s*:\s*0" -and $log -match "UVM_FATAL\s*:\s*0" -and $log -notmatch "\$error") {
        Write-Host "PASS: $t" -ForegroundColor Green
        $Pass++
        $Results += [PSCustomObject]@{ Test = $t; Status = "PASS" }
    } else {
        Write-Host "FAIL: $t (check $logFile)" -ForegroundColor Red
        $Fail++
        $Results += [PSCustomObject]@{ Test = $t; Status = "FAIL" }
    }
}

Write-Host ""
Write-Host "========== Regression Summary =========="
$Results | Format-Table -AutoSize
Write-Host "Passed: $Pass  Failed: $Fail"
if ($Fail -gt 0) { exit 1 }
exit 0
