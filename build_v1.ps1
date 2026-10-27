# Builds the inventory mod from src_v1\ on top of the VANILLA list files: the three list screens, the
# HUD patch (src_v1\hud), the Lua scripts and the UI element files.
# Output: build\zz_inventory_overhaul (a complete mod folder). Add -Install to copy it into the game's
# Mods folder and the plugin into Bin\Win64MasterMasterSteamPGO.
param([switch]$Install)
$ErrorActionPreference = 'Stop'
$here  = Split-Path -Parent $MyInvocation.MyCommand.Path
$tools = 'F:\GAME STUFF\tools'
$game  = 'C:\Program Files (x86)\Steam\steamapps\common\KingdomComeDeliverance2'
$modId = 'zz_inventory_overhaul'
$tmp   = Join-Path $env:TEMP 'kcd2_inventory_overhaul_build'
$mod   = "$here\build\$modId"
Remove-Item -Recurse -Force $tmp, $mod -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$tmp\out", "$mod\Data" | Out-Null

$map = @{ 'ApseInventoryList' = 'list'; 'ItemTransfer' = 'transfer'; 'ItemSelection' = 'selection' }
foreach ($n in $map.Keys) {
    $imp = "$tmp\imp_$n\scripts"
    New-Item -ItemType Directory -Force "$imp\__Packages", "$imp\frame_1" | Out-Null
    Copy-Item "$here\src_v1\pkg\scripts\__Packages\*.as" "$imp\__Packages\"
    Remove-Item "$imp\__Packages\InvHeaders.as" -ErrorAction SilentlyContinue
    Copy-Item "$here\src_v1\$($map[$n])\scripts\frame_1\DoAction.as" "$imp\frame_1\"
    Copy-Item "$here\vanilla_original\$n.gfx" "$tmp\$n.swf"
    $ErrorActionPreference = 'Continue'
    $log = & "$tools\jre\bin\java.exe" -jar "$tools\ffdec\ffdec-cli.jar" -importScript "$tmp\$n.swf" "$tmp\out\$n.gfx" $imp 2>&1
    $ErrorActionPreference = 'Stop'
    $sev = $log | ? { "$_" -match 'SEVERE' }
    if ($sev) { throw "compile error in $n`: $($sev -join ' | ')" }
    if (-not (Test-Path "$tmp\out\$n.gfx")) { throw "compile failed: $n" }
}
# HUD: bottom button hints (Expand / Collapse / Expand all) and the item-hint filter on title rows
$imp = "$tmp\imp_hud\scripts"
New-Item -ItemType Directory -Force "$imp\frame_1" | Out-Null
Copy-Item "$here\src_v1\hud\scripts\frame_1\DoAction.as" "$imp\frame_1\"
Copy-Item "$here\vanilla_original\hud.gfx" "$tmp\hud.swf"
$ErrorActionPreference = 'Continue'
$log = & "$tools\jre\bin\java.exe" -jar "$tools\ffdec\ffdec-cli.jar" -importScript "$tmp\hud.swf" "$tmp\out\hud.gfx" $imp 2>&1
$ErrorActionPreference = 'Stop'
$sev = $log | ? { "$_" -match 'SEVERE' }
if ($sev) { throw "compile error in hud`: $($sev -join ' | ')" }
if (-not (Test-Path "$tmp\out\hud.gfx")) { throw "compile failed: hud" }

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open("$mod\Data\$modId.pak", 'Create')
$none = [System.IO.Compression.CompressionLevel]::NoCompression
foreach ($n in $map.Keys) {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$tmp\out\$n.gfx", "Libs/UI/$n.gfx", $none) | Out-Null
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$here\src_v1\uielements\$n.xml", "Libs/UI/UIElements/$n.xml", $none) | Out-Null
}
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$tmp\out\hud.gfx", "Libs/UI/hud.gfx", $none) | Out-Null
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$here\src_v1\hud\HUD.xml", "Libs/UI/UIElements/HUD.xml", $none) | Out-Null
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$here\src_v1\lua\$modId.lua", "Scripts/mods/$modId.lua", $none) | Out-Null
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$here\src_v1\lua\${modId}_items.lua", "Scripts/mods/${modId}_items.lua", $none) | Out-Null
$zip.Dispose()
# English name fixes (inconsistent spellings across colour variants) - other languages untouched
if (Test-Path "$here\data\text_ui_items.xml") {
    New-Item -ItemType Directory -Force "$mod\Localization" | Out-Null
    $lz = [System.IO.Compression.ZipFile]::Open("$mod\Localization\English_xml.pak", 'Create')
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($lz, "$here\data\text_ui_items.xml", "text_ui_items.xml", $none) | Out-Null
    $lz.Dispose()
}
Copy-Item "$here\src_v1\mod.manifest" "$mod\"
"Built $mod"
if ($Install) {
    Remove-Item -Recurse -Force "$game\Mods\$modId" -ErrorAction SilentlyContinue
    Copy-Item -Recurse $mod "$game\Mods\"
    "Installed into $game\Mods\$modId"
    Copy-Item "$here\asi\Inventory_Overhaul.asi" "$game\Bin\Win64MasterMasterSteamPGO\" -Force
    "Installed Inventory_Overhaul.asi"
}
