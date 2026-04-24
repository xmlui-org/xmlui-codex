param(
  [switch]$CreateProject,
  [switch]$SkipProjectPrompt,
  [switch]$NoRun,
  [string]$Template = "xmlui-weather",
  [string]$ProjectName = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot "common.ps1")

function Resolve-ProjectPath {
  param([Parameter(Mandatory = $true)][string]$PathInput)

  if ($PathInput -eq "~") {
    return $HOME
  }

  if ($PathInput.StartsWith("~/") -or $PathInput.StartsWith("~\")) {
    $suffix = $PathInput.Substring(2)
    return Join-Path $HOME $suffix
  }

  return $PathInput
}

$defaultProjectPath = Join-Path $HOME "xmlui-weather"
$cwdProjectPath = Join-Path (Get-Location).Path "xmlui-weather"

& (Join-Path $scriptRoot "preflight.ps1")

$xmluiDetected = Get-Command "xmlui.exe" -ErrorAction SilentlyContinue
if (-not $xmluiDetected) {
  & (Join-Path $scriptRoot "install-cli.ps1")
}

& (Join-Path $scriptRoot "configure-mcp.ps1")

if ($CreateProject) {
  if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = $defaultProjectPath
  } else {
    $ProjectName = Resolve-ProjectPath -PathInput $ProjectName
  }
  & (Join-Path $scriptRoot "dev-setup.ps1") -Template $Template -ProjectName $ProjectName -NoRun:$NoRun
} elseif (-not $SkipProjectPrompt) {
  $canPrompt = $true
  try {
    $canPrompt = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected
  } catch {
    $canPrompt = $false
  }

  if ($canPrompt) {
    try {
      $scaffoldAnswer = Read-Host "Scaffold starter project ($Template)? [Y/n]"
      if (-not [string]::IsNullOrWhiteSpace($scaffoldAnswer) -and $scaffoldAnswer.Trim().ToLowerInvariant().StartsWith("n")) {
        Write-Log "Skipping starter project scaffolding."
        exit 0
      }

      Write-Log "Choose where to create the starter project."
      Write-Log "Recommended: $defaultProjectPath"
      Write-Log "Alternative (current directory): $cwdProjectPath"
      $projectAnswer = Read-Host "Project path [$defaultProjectPath]"
      if ([string]::IsNullOrWhiteSpace($projectAnswer)) {
        $ProjectName = $defaultProjectPath
      } else {
        $ProjectName = Resolve-ProjectPath -PathInput $projectAnswer
      }

      & (Join-Path $scriptRoot "dev-setup.ps1") -Template $Template -ProjectName $ProjectName -NoRun:$NoRun
    } catch {
      $ProjectName = $defaultProjectPath
      Write-WarnLog "Interactive prompt unavailable; creating starter project at $ProjectName."
      & (Join-Path $scriptRoot "dev-setup.ps1") -Template $Template -ProjectName $ProjectName -NoRun:$NoRun
    }
  } else {
    Write-Log "Non-interactive shell detected; starter project scaffolding still needs a choice."
    Write-Log "Scaffold starter project ($Template)? [Y/n]"
    Write-Log "Recommended path: $defaultProjectPath"
    Write-Log "Alternative (current directory): $cwdProjectPath"
    Write-Log "Codex should ask the user this question in chat now."
    Write-Log "Do not skip scaffolding unless the user explicitly answers no."
    Write-Log "Answer yes by rerunning with -CreateProject [-ProjectName <path>]."
    Write-Log "Answer no by rerunning with -SkipProjectPrompt."
    exit 2
  }
}
