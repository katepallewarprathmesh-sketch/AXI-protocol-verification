# Direct Questa compile/run without GNU Make
param(
    [string]$Test = "axi_smoke_test",
    [int]$Seed = 1,
    [switch]$CompileOnly,
    [switch]$Gui
)

$ErrorActionPreference = "Stop"
$SimDir = $PSScriptRoot
Set-Location $SimDir

# Set QUESTA_HOME to your Questa install, e.g. C:\intelFPGA\*\questa_fe_win64
if (-not $env:QUESTA_HOME) {
    $candidates = @(
        "C:\questasim64_10.7c\win64",
        "C:\modelsim_ase\win32aloem"
    )
    foreach ($c in $candidates) {
        if (Test-Path "$c\vlog.exe") { $env:QUESTA_HOME = $c; break }
    }
}

if (-not $env:QUESTA_HOME -or -not (Test-Path "$env:QUESTA_HOME\vlog.exe")) {
    Write-Error "Questa not found. Set QUESTA_HOME to your Questa win64 directory."
}

$vlog = Join-Path $env:QUESTA_HOME "vlog.exe"
$vopt = Join-Path $env:QUESTA_HOME "vopt.exe"
$vsim = Join-Path $env:QUESTA_HOME "vsim.exe"

if (-not (Test-Path "work")) {
    $vlib = Join-Path $env:QUESTA_HOME "vlib.exe"
    & $vlib work
}

$inc = "+incdir+$SimDir/../tb/interfaces"
$uvm = "-uvmver 1.2"

Write-Host "Compiling..." -ForegroundColor Cyan
& $vlog -work work -sv -timescale 1ns/1ps $inc $uvm -f compile.f
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $vopt -work work +acc -debugdb tb_top -o tb_top_opt
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($CompileOnly) { Write-Host "Compile OK"; exit 0 }

if (-not (Test-Path "logs")) { New-Item -ItemType Directory logs | Out-Null }
$log = "logs\${Test}_${Seed}.log"

Write-Host "Running $Test (seed=$Seed)..." -ForegroundColor Cyan
if ($Gui) {
    & $vsim -work work -gui tb_top_opt -sv_seed $Seed "+UVM_TESTNAME=$Test"
} else {
    & $vsim -work work -c tb_top_opt -sv_seed $Seed "+UVM_TESTNAME=$Test" `
        -l $log -do "run -all; quit -f"
    Get-Content $log -Tail 30
}
