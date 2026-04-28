param(
  [string]$Ref = 'main',
  [switch]$DryRun,
  [string[]]$Tool = @(),
  [string]$SourceDir
)

$ErrorActionPreference = 'Stop'

function Write-Usage {
  @'
Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Ref main
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Tool claude_code -Tool codex
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -SourceDir C:\path\to\dropshippinglite-agent-skills
'@
}

if ($args -contains '-h' -or $args -contains '--help') {
  Write-Usage
  exit 0
}

Write-Host 'Windows installer entry detected.'
Write-Host 'This repository already reserves install.ps1 as the official Windows installation entrypoint.'
Write-Host ''
Write-Host 'Current status: Windows installation logic is not implemented in this phase.'
Write-Host ''
Write-Host 'Expected next step for the Windows maintainer:'
Write-Host '- Add Windows-specific tool directory detection'
Write-Host '- Add zip download and extract flow without git or npm'
Write-Host '- Install the NS Client skills into all detected supported tools'
Write-Host '- Preserve the same flags as install.sh: Ref, DryRun, Tool, SourceDir'
Write-Host ''
Write-Host "Current parameters:"
Write-Host "Ref=$Ref"
Write-Host "DryRun=$DryRun"
Write-Host "Tool=$($Tool -join ',')"
Write-Host "SourceDir=$SourceDir"
exit 1
