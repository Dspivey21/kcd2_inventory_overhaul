# Builds Inventory_Overhaul.asi with w64devkit's GCC. Add -Install to copy it next to the other .asi plugins.
param([switch]$Install)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$gcc  = 'F:\GAME STUFF\AI Tool Scripts\w64devkit\bin\gcc.exe'
if (-not (Test-Path $gcc)) { throw "gcc not found at $gcc" }
$env:PATH = (Split-Path $gcc) + ';' + $env:PATH
$asi = Join-Path $here 'Inventory_Overhaul.asi'
$ErrorActionPreference = 'Continue'
& $gcc -shared -O2 -s -static -o $asi (Join-Path $here 'colourgroup_keys.c') -lkernel32 -luser32
if ($LASTEXITCODE -ne 0) { throw "build failed" }
$ErrorActionPreference = 'Stop'
"built $asi ($((Get-Item $asi).Length) bytes)"
if ($Install) {
    $bin = 'C:\Program Files (x86)\Steam\steamapps\common\KingdomComeDeliverance2\Bin\Win64MasterMasterSteamPGO'
    Copy-Item $asi (Join-Path $bin 'Inventory_Overhaul.asi') -Force
    "installed to $bin"
}

