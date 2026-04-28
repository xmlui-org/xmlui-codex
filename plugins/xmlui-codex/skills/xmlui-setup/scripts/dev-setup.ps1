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

Write-Log "Project ready: $ProjectName"
Write-Log "To start the dev server, run:"
Write-Log "  cd $ProjectName"
Write-Log "  $xmluiCmd run"

if ($NoRun) {
  Write-Log "Skipping dev server start because -NoRun was provided."
  exit 0
}

$devUrl = Get-XmluiDevUrl
if (Test-HttpUrl -Url $devUrl) {
  Write-Log "Existing dev server already responds at $devUrl"
  Write-Log "Skipping a second xmlui run for: $ProjectName"
  exit 0
}

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectName).Path
$xmluiCmd = Get-XmluiCommand
$xmluiExecPath = if (Test-Path -LiteralPath $xmluiCmd) { $xmluiCmd } else {
  $xmluiCmdInfo = Get-Command $xmluiCmd -ErrorAction SilentlyContinue
  if (-not $xmluiCmdInfo) {
    Fail "Unable to resolve xmlui command for starting the dev server."
  }

  if ($xmluiCmdInfo.Source) { $xmluiCmdInfo.Source } else { $xmluiCmdInfo.Path }
}

$stdoutLogPath = Join-Path $resolvedProjectPath ".xmlui-codex-dev.out.log"
$stderrLogPath = Join-Path $resolvedProjectPath ".xmlui-codex-dev.err.log"
Write-Log "Starting dev server in a separate process..."
$process = Start-Process -FilePath $xmluiExecPath -ArgumentList "run" -WorkingDirectory $resolvedProjectPath -RedirectStandardOutput $stdoutLogPath -RedirectStandardError $stderrLogPath -PassThru

if (Wait-HttpUrl -Url $devUrl -TimeoutSeconds 15) {
  Write-Log "Dev server is responding at $devUrl"
  Write-Log "Dev server started for: $resolvedProjectPath"
  exit 0
}

$process.Refresh()
if (-not $process.HasExited) {
  Write-WarnLog "Started xmlui run (pid $($process.Id)), but no response arrived from $devUrl within 15 seconds."
} else {
  Write-WarnLog "xmlui run exited before $devUrl became reachable."
}
Fail "Dev server did not become ready. Check $stdoutLogPath and $stderrLogPath."
