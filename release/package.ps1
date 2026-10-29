# Packs the release zips from build\zz_inventory_overhaul (run build_v1.ps1 first) and asi\Inventory_Overhaul.asi.
# Main zip:   zz_inventory_overhaul\{Data,Localization,mod.manifest} at the root (what Vortex and manual installs expect)
# Plugin zip: Bin\Win64MasterMasterSteamPGO\Inventory_Overhaul.asi, an optional download for controller users
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
$modId = 'zz_inventory_overhaul'
$mod = "$root\build\$modId"
if (-not (Test-Path "$mod\mod.manifest")) { throw "no build: run build_v1.ps1 first" }
[xml]$m = Get-Content "$mod\mod.manifest"
$ver = $m.kcd_mod.info.version
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

function Pack-Zip($zip, $stage) {
    Remove-Item $zip -ErrorAction SilentlyContinue
    # entries are added one by one so their names use forward slashes (CreateFromDirectory on Windows PowerShell
    # writes backslashes, which some extractors and mod managers read as part of the file name)
    $z = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
    Get-ChildItem -Recurse -File $stage | ForEach-Object {
        $rel = $_.FullName.Substring($stage.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $_.FullName, $rel, 'Optimal') | Out-Null
    }
    $z.Dispose()
    "Packed $zip"
}

$stage = Join-Path $env:TEMP 'uio_release'
Remove-Item -Recurse -Force $stage -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $stage | Out-Null
Copy-Item -Recurse $mod "$stage\"
Pack-Zip "$here\Ultimate_Inventory_Overhaul_$ver.zip" $stage

Remove-Item -Recurse -Force $stage
New-Item -ItemType Directory -Force "$stage\Bin\Win64MasterMasterSteamPGO" | Out-Null
Copy-Item "$root\asi\Inventory_Overhaul.asi" "$stage\Bin\Win64MasterMasterSteamPGO\"
Pack-Zip "$here\Ultimate_Inventory_Overhaul_Controller_Plugin_$ver.zip" $stage
Remove-Item -Recurse -Force $stage

# No-HUD variant (build_v1.ps1 -NoHud): same mod without hud.gfx / HUD.xml, for players who run a HUD mod
$nohud = "$root\build\nohud\$modId"
if (Test-Path "$nohud\mod.manifest") {
    [xml]$m2 = Get-Content "$nohud\mod.manifest"
    if ($m2.kcd_mod.info.version -ne $ver) { throw "no-HUD build is version $($m2.kcd_mod.info.version), main build is ${ver}: rebuild with -NoHud" }
    New-Item -ItemType Directory -Force $stage | Out-Null
    Copy-Item -Recurse $nohud "$stage\"
    Pack-Zip "$here\Ultimate_Inventory_Overhaul_No_HUD_$ver.zip" $stage
    Remove-Item -Recurse -Force $stage
}

Get-ChildItem "$here\*.zip" | Select-Object Name, Length
