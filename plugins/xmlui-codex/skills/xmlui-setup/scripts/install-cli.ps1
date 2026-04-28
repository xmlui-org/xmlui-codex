Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot/common.ps1"

Write-Log "Installing XMLUI CLI"

$downloadUrl = "https://github.com/xmlui-org/xmlui-cli/releases/latest/download/xmlui-win-x64.zip"
$installDir = Get-XmluiInstallDir

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

$tmpDir = Join-Path $env:TEMP ("xmlui-cli-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
$archivePath = Join-Path $tmpDir "xmlui-cli.zip"

try {
  Write-Log "Downloading XMLUI CLI from $downloadUrl"
  Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath

  Write-Log "Extracting archive"
  Expand-Archive -Path $archivePath -DestinationPath $tmpDir -Force

  $exePath = Get-ChildItem -Path $tmpDir -Recurse -File -Filter "xmlui.exe" | Select-Object -First 1 -ExpandProperty FullName
  if (-not $exePath) {
    Fail "Could not find xmlui.exe in downloaded archive."
  }

  $targetPath = Join-Path $installDir "xmlui.exe"
  Copy-Item -LiteralPath $exePath -Destination $targetPath -Force
  Write-Log "Installed: $targetPath"

  $xmluiCmd = Get-XmluiCommand
  if ($xmluiCmd) {
    Write-Log "Binary managed by xmlui-codex at '$xmluiCmd'"
  } else {
    Write-WarnLog "CLI install completed but the managed binary could not be resolved."
  }
}
finally {
  if (Test-Path -LiteralPath $tmpDir) {
    Remove-Item -LiteralPath $tmpDir -Recurse -Force
  }
}
