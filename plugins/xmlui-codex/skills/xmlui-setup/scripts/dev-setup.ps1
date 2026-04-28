param(
  [string]$Template = "xmlui-weather",
  [string]$ProjectName = "xmlui-weather",
  [switch]$NoRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot/common.ps1"

$xmluiCmd = Get-XmluiCommand
if (-not $xmluiCmd) {
  Fail "xmlui CLI is not available. Run install-cli first."
}

if (Test-Path -LiteralPath $ProjectName) {
  Write-WarnLog "Directory '$ProjectName' already exists. Skipping project init."
} else {
  Write-Log "Creating project: $xmluiCmd new $Template --output $ProjectName"
  $null = Invoke-Xmlui new $Template --output $ProjectName
  if ($LASTEXITCODE -ne 0) {
    Fail "Project creation failed."
  }
}

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectName).Path

Write-Log "Project ready: $resolvedProjectPath"
Write-Log "To start the dev server, run this in a separate terminal:"
Write-Log "  cd $resolvedProjectPath; & '$xmluiCmd' run"
