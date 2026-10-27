# Packs the release zip from build\zz_inventory_overhaul (run build_v1.ps1 first) and asi\Inventory_Overhaul.asi.
# Layout: Mods\zz_inventory_overhaul\..., Bin\Win64MasterMasterSteamPGO\Inventory_Overhaul.asi, README.txt
# so the archive extracts straight into the game folder. Output: release\Ultimate_Inventory_Overhaul_<version>.zip
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
$modId = 'zz_inventory_overhaul'
$mod = "$root\build\$modId"
if (-not (Test-Path "$mod\mod.manifest")) { throw "no build: run build_v1.ps1 first" }
[xml]$m = Get-Content "$mod\mod.manifest"
$ver = $m.kcd_mod.info.version
$stage = Join-Path $env:TEMP 'uio_release'
Remove-Item -Recurse -Force $stage -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$stage\Mods", "$stage\Bin\Win64MasterMasterSteamPGO" | Out-Null
Copy-Item -Recurse $mod "$stage\Mods\"
Copy-Item "$root\asi\Inventory_Overhaul.asi" "$stage\Bin\Win64MasterMasterSteamPGO\"
Copy-Item "$here\README.txt" "$stage\"
$zip = "$here\Ultimate_Inventory_Overhaul_$ver.zip"
Remove-Item $zip -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
# entries are added one by one so their names use forward slashes (CreateFromDirectory on Windows PowerShell
# writes backslashes, which some extractors and mod managers read as part of the file name)
$z = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
Get-ChildItem -Recurse -File $stage | ForEach-Object {
    $rel = $_.FullName.Substring($stage.Length + 1).Replace('\', '/')
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $_.FullName, $rel, 'Optimal') | Out-Null
}
$z.Dispose()
Remove-Item -Recurse -Force $stage
"Packed $zip"
Get-ChildItem $zip | Select-Object Name, Length
