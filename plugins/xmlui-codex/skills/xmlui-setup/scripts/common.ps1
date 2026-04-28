Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Host "[xmlui-codex] $Message"
}

function Write-WarnLog {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Warning "[xmlui-codex] $Message"
}

function Fail {
  param([Parameter(Mandatory = $true)][string]$Message)
  throw "[xmlui-codex] ERROR: $Message"
}

function Require-Command {
  param([Parameter(Mandatory = $true)][string]$Name)
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $cmd) {
    Fail "Missing required command: $Name"
  }
}

function Get-CodexCommand {
  $candidates = @("codex.cmd", "codex")
  foreach ($candidate in $candidates) {
    $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($cmd) {
      return $candidate
    }
  }
  Fail "Codex CLI not found. Install Codex and ensure codex/codex.cmd is on PATH."
}

function Get-XmluiCommand {
  $pluginManagedPath = Get-XmluiCliPath
  if (Test-Path -LiteralPath $pluginManagedPath) {
    return $pluginManagedPath
  }
  return $null
}

function Get-XmluiInstallDir {
  if ($env:XMLUI_CLI_INSTALL_DIR) {
    return $env:XMLUI_CLI_INSTALL_DIR
  }

  return Join-Path $HOME ".codex/plugins/data/xmlui-codex/bin"
}

function Get-XmluiCliPath {
  return Join-Path (Get-XmluiInstallDir) "xmlui.exe"
}

function Get-XmluiDevHost {
  if ($env:XMLUI_DEV_HOST) {
    return $env:XMLUI_DEV_HOST
  }

  return "127.0.0.1"
}

function Get-XmluiDevPort {
  if ($env:XMLUI_DEV_PORT) {
    return $env:XMLUI_DEV_PORT
  }

  return "8080"
}

function Get-XmluiDevUrl {
  return "http://$(Get-XmluiDevHost):$(Get-XmluiDevPort)/"
}

function Test-HttpUrl {
  param([Parameter(Mandatory = $true)][string]$Url)

  try {
    & curl.exe --silent --output NUL --max-time 2 $Url | Out-Null
    return ($LASTEXITCODE -eq 0)
  } catch {
    return $false
  }
}

function Wait-HttpUrl {
  param(
    [Parameter(Mandatory = $true)][string]$Url,
    [int]$TimeoutSeconds = 15
  )

  for ($attempt = 0; $attempt -lt $TimeoutSeconds; $attempt++) {
    if (Test-HttpUrl -Url $Url) {
      return $true
    }
    Start-Sleep -Seconds 1
  }

  return $false
}

function Invoke-Codex {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
  $codexCmd = Get-CodexCommand
  & $codexCmd @Args
  return $LASTEXITCODE
}

function Invoke-Xmlui {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
  $xmluiCmd = Get-XmluiCommand
  if (-not $xmluiCmd) {
    Fail "XMLUI CLI is not available."
  }
  & $xmluiCmd @Args
  return $LASTEXITCODE
}
