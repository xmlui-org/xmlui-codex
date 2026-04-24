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
  Fail "xmlui CLI is not available on PATH. Run install-cli first."
}

if (Test-Path -LiteralPath $ProjectName) {
  Write-WarnLog "Directory '$ProjectName' already exists. Skipping project init."
  exit 0
}

Write-Log "Creating project: xmlui new $Template --output $ProjectName"
$null = Invoke-Xmlui new $Template --output $ProjectName
if ($LASTEXITCODE -ne 0) {
  Fail "Project creation failed."
}

Write-Log "Project ready: $ProjectName"
Write-Log "To start the dev server, run:"
Write-Log "  cd $ProjectName"
Write-Log "  xmlui run"

if ($NoRun) {
  Write-Log "Skipping dev server start because -NoRun was provided."
  exit 0
}

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectName).Path
$xmluiCmd = Get-XmluiCommand
$xmluiCmdInfo = Get-Command $xmluiCmd -ErrorAction SilentlyContinue
if (-not $xmluiCmdInfo) {
  Fail "Unable to resolve xmlui command for starting the dev server."
}

$xmluiExecPath = if ($xmluiCmdInfo.Source) { $xmluiCmdInfo.Source } else { $xmluiCmdInfo.Path }
Write-Log "Starting dev server in a separate process..."
Start-Process -FilePath $xmluiExecPath -ArgumentList "run" -WorkingDirectory $resolvedProjectPath | Out-Null
Write-Log "Dev server started for: $resolvedProjectPath"
