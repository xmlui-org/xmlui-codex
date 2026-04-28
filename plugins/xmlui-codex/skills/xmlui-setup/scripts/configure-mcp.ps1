Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. "$PSScriptRoot/common.ps1"

Write-Log "Configuring XMLUI MCP server for Codex"

$xmluiPath = Get-XmluiCliPath
if (-not (Test-Path -LiteralPath $xmluiPath)) {
  Fail "XMLUI CLI not found at $xmluiPath. Run install-cli first."
}

$existingConfig = & (Get-CodexCommand) mcp get xmlui 2>$null
$existingExitCode = $LASTEXITCODE
if ($existingExitCode -eq 0) {
  if ($existingConfig -match [regex]::Escape("command: $xmluiPath")) {
    Write-Log "MCP server 'xmlui' already configured with plugin-managed CLI"
    exit 0
  }

  $existingCommand = $null
  if ($existingConfig -match "(?m)^\s*command:\s*(.+?)\s*$") {
    $existingCommand = $Matches[1]
  }

  $existingCommandWorks = $false
  if ($existingCommand) {
    if (Get-Command $existingCommand -ErrorAction SilentlyContinue) {
      $existingCommandWorks = $true
    }
  }

  if ($existingCommand -and -not $existingCommandWorks) {
    Write-WarnLog "MCP server 'xmlui' command '$existingCommand' is not executable; replacing with plugin-managed CLI."
    $null = Invoke-Codex mcp remove xmlui
    if ($LASTEXITCODE -ne 0) {
      Fail "Failed to remove existing MCP server 'xmlui'."
    }
  } elseif ($existingConfig -match "(?m)^\s*args:\s+mcp\s*$") {
    Write-Log "Updating MCP server 'xmlui' to use $xmluiPath"
    $null = Invoke-Codex mcp remove xmlui
    if ($LASTEXITCODE -ne 0) {
      Fail "Failed to remove existing MCP server 'xmlui'."
    }
  } else {
    Write-WarnLog "MCP server 'xmlui' already exists with a custom command or arguments; leaving it unchanged."
    Write-WarnLog "To point it at the plugin-managed CLI, run:"
    Write-WarnLog "  codex mcp remove xmlui"
    Write-WarnLog "  codex mcp add xmlui -- $xmluiPath mcp"
    exit 0
  }
}

$null = Invoke-Codex mcp add xmlui -- $xmluiPath mcp
if ($LASTEXITCODE -ne 0) {
  Fail "Failed to configure MCP with 'codex mcp add'."
}

$existingConfig = & (Get-CodexCommand) mcp get xmlui 2>$null
if ($LASTEXITCODE -eq 0 -and $existingConfig -match [regex]::Escape("command: $xmluiPath")) {
  Write-Log "Verified MCP server 'xmlui'"
} else {
  Fail "MCP server 'xmlui' not found after add attempt"
}
