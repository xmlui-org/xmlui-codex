param(
  [switch]$CreateProject,
  [string]$Template = "xmlui-weather",
  [string]$ProjectName = "xmlui-weather"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $scriptRoot "preflight.ps1")

$xmluiDetected = Get-Command "xmlui.exe" -ErrorAction SilentlyContinue
if (-not $xmluiDetected) {
  & (Join-Path $scriptRoot "install-cli.ps1")
}

& (Join-Path $scriptRoot "configure-mcp.ps1")

if ($CreateProject) {
  & (Join-Path $scriptRoot "dev-setup.ps1") -Template $Template -ProjectName $ProjectName
}
