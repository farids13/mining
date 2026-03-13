$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$startupDir = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupDir "Mining Portable.lnk"
$targetPath = Join-Path $root "scripts\windows\run-autostart.cmd"

if (-not (Test-Path $targetPath)) {
    throw "Script autostart tidak ditemukan: $targetPath"
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.WorkingDirectory = Split-Path $targetPath -Parent
$shortcut.WindowStyle = 1
$shortcut.Description = "Portable mining launcher"
$shortcut.Save()

Write-Host "Autostart aktif: $shortcutPath"

