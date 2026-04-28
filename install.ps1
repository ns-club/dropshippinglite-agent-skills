$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$script:RepoOwner = if ($env:DROPSHIPPINGLITE_AGENT_SKILLS_OWNER) { $env:DROPSHIPPINGLITE_AGENT_SKILLS_OWNER } else { 'ns-club' }
$script:RepoName = if ($env:DROPSHIPPINGLITE_AGENT_SKILLS_REPO) { $env:DROPSHIPPINGLITE_AGENT_SKILLS_REPO } else { 'dropshippinglite-agent-skills' }
$script:Ref = 'main'
$script:DryRun = $false
$script:Tool = @()
$script:SourceDir = $null

function Write-Usage {
  @'
Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Ref main
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Tool claude_code -Tool codex
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -SourceDir C:\path\to\dropshippinglite-agent-skills

Also accepted for cmd-style callers:
  install.cmd --dry-run
  install.cmd --ref main
  install.cmd --tool claude_code --tool codex
  install.cmd --source-dir C:\path\to\dropshippinglite-agent-skills

Options:
  -DryRun, --dry-run       Show detected tools and planned actions without changing files
  -Ref, --ref REF          Install from the specified GitHub branch or tag (default: main)
  -Tool, --tool KEY        Limit installation to selected tool key(s); may be repeated
  -SourceDir, --source-dir Use a local unpacked repository instead of downloading from GitHub
  -h, --help              Show this help
'@
}

function Add-SelectedTool {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    throw 'tool key cannot be empty'
  }

  foreach ($item in ($Value -split ',')) {
    $trimmed = $item.Trim()
    if ($trimmed) {
      $script:Tool += $trimmed
    }
  }
}

function Get-NextArgumentValue {
  param(
    [string[]]$Arguments,
    [ref]$Index,
    [string]$Name
  )

  if (($Index.Value + 1) -ge $Arguments.Count) {
    throw "missing value for argument: $Name"
  }

  $Index.Value += 1
  return $Arguments[$Index.Value]
}

function Parse-Arguments {
  param([string[]]$Arguments)

  for ($i = 0; $i -lt $Arguments.Count; $i++) {
    $arg = $Arguments[$i]

    if ($arg -match '^(--help|-h|/h|/\?)$') {
      Write-Usage
      exit 0
    }

    if ($arg -match '^(--dry-run|-dryrun|-dry-run|/dryrun|/dry-run)$') {
      $script:DryRun = $true
      continue
    }

    if ($arg -match '^(--ref|-ref|/ref)=(.+)$') {
      $script:Ref = $Matches[2]
      continue
    }

    if ($arg -match '^(--ref|-ref|/ref)$') {
      $script:Ref = Get-NextArgumentValue -Arguments $Arguments -Index ([ref]$i) -Name $arg
      continue
    }

    if ($arg -match '^(--tool|-tool|/tool)=(.+)$') {
      Add-SelectedTool $Matches[2]
      continue
    }

    if ($arg -match '^(--tool|-tool|/tool)$') {
      Add-SelectedTool (Get-NextArgumentValue -Arguments $Arguments -Index ([ref]$i) -Name $arg)
      continue
    }

    if ($arg -match '^(--source-dir|-sourcedir|-source-dir|/sourcedir|/source-dir)=(.+)$') {
      $script:SourceDir = $Matches[2]
      continue
    }

    if ($arg -match '^(--source-dir|-sourcedir|-source-dir|/sourcedir|/source-dir)$') {
      $script:SourceDir = Get-NextArgumentValue -Arguments $Arguments -Index ([ref]$i) -Name $arg
      continue
    }

    throw "unknown argument: $arg"
  }
}

Parse-Arguments -Arguments $args

$script:UseColor = (-not [Console]::IsOutputRedirected) -and [string]::IsNullOrEmpty($env:NO_COLOR)

function Write-Section {
  param([string]$Message)
  Write-Host ''
  if ($script:UseColor) {
    Write-Host $Message -ForegroundColor Blue
  } else {
    Write-Host $Message
  }
}

function Write-Info {
  param([string]$Message)
  if ($script:UseColor) {
    Write-Host $Message -ForegroundColor Cyan
  } else {
    Write-Host $Message
  }
}

function Write-Success {
  param([string]$Message)
  if ($script:UseColor) {
    Write-Host $Message -ForegroundColor Green
  } else {
    Write-Host $Message
  }
}

function Stop-Install {
  param([string]$Message)
  if ($script:UseColor) {
    Write-Host "ERROR: $Message" -ForegroundColor Yellow -ErrorAction Continue
  } else {
    Write-Host "ERROR: $Message" -ErrorAction Continue
  }
  exit 1
}

function Save-Url {
  param(
    [string]$Url,
    [string]$OutputPath
  )

  if (Test-Path -LiteralPath $OutputPath) {
    Remove-Item -LiteralPath $OutputPath -Force
  }

  try {
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $OutputPath
  } catch {
    if (Test-Path -LiteralPath $OutputPath) {
      Remove-Item -LiteralPath $OutputPath -Force
    }
    throw
  }
}

function Expand-ZipArchive {
  param(
    [string]$ArchivePath,
    [string]$DestinationPath
  )

  if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $DestinationPath -Force
    return
  }

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $DestinationPath)
}

function Get-ScriptDirectory {
  $psCommandPathVariable = Get-Variable -Name PSCommandPath -Scope Script -ErrorAction SilentlyContinue
  if ($psCommandPathVariable -and $psCommandPathVariable.Value) {
    return (Split-Path -Parent $psCommandPathVariable.Value)
  }

  $myInvocationVariable = Get-Variable -Name MyInvocation -Scope Script -ErrorAction SilentlyContinue
  $myInvocationValue = if ($myInvocationVariable) { $myInvocationVariable.Value } else { $null }
  if ($myInvocationValue -and $myInvocationValue.MyCommand) {
    $pathProperty = $myInvocationValue.MyCommand.PSObject.Properties['Path']
    if ($pathProperty -and $pathProperty.Value) {
      return (Split-Path -Parent $pathProperty.Value)
    }
  }

  return $null
}

function Resolve-LocalSourceRoot {
  if ($script:SourceDir) {
    if (-not (Test-Path -LiteralPath $script:SourceDir -PathType Container)) {
      Stop-Install "local source directory not found: $($script:SourceDir)"
    }
    return (Resolve-Path -LiteralPath $script:SourceDir).Path
  }

  $scriptDir = Get-ScriptDirectory
  if ($scriptDir) {
    $sharedSkillDir = Join-Path $scriptDir 'ns-client-ai-shared'
    if (Test-Path -LiteralPath $sharedSkillDir -PathType Container) {
      return $scriptDir
    }
  }

  return $null
}

function Download-SourceRoot {
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  } catch {
  }

  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dropshippinglite-agent-skills.{0}" -f ([guid]::NewGuid().ToString('N')))
  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  $archivePath = Join-Path $tempDir 'source.zip'

  $branchUrl = "https://github.com/$script:RepoOwner/$script:RepoName/archive/refs/heads/$script:Ref.zip"
  $tagUrl = "https://github.com/$script:RepoOwner/$script:RepoName/archive/refs/tags/$script:Ref.zip"

  try {
    Save-Url -Url $branchUrl -OutputPath $archivePath
  } catch {
    try {
      Save-Url -Url $tagUrl -OutputPath $archivePath
    } catch {
      Stop-Install "failed to download repository archive for ref: $($script:Ref)"
    }
  }

  Expand-ZipArchive -ArchivePath $archivePath -DestinationPath $tempDir

  $skillDir = Get-ChildItem -LiteralPath $tempDir -Directory -Recurse -Filter 'ns-client-ai-shared' | Select-Object -First 1
  if (-not $skillDir) {
    Stop-Install 'downloaded archive does not contain ns-client-ai-shared'
  }

  return $skillDir.Parent.FullName
}

function Get-SkillSourceRoot {
  $localRoot = Resolve-LocalSourceRoot
  if ($localRoot) {
    return $localRoot
  }
  return (Download-SourceRoot)
}

function Get-YamlName {
  param([string]$SkillMarkdownPath)

  foreach ($line in Get-Content -LiteralPath $SkillMarkdownPath) {
    if ($line -match '^name:\s*(.+)$') {
      return $Matches[1].Trim().Trim('"').Trim("'")
    }
  }

  return ''
}

function Get-InstallableSkills {
  param([string]$SourceRoot)

  if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    Stop-Install "skill source directory not found: $SourceRoot"
  }

  $found = @()
  foreach ($path in (Get-ChildItem -LiteralPath $SourceRoot -Directory | Sort-Object Name)) {
    $skillName = $path.Name
    $skillMarkdown = Join-Path $path.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillMarkdown -PathType Leaf)) {
      continue
    }

    $declaredName = Get-YamlName -SkillMarkdownPath $skillMarkdown
    if (-not $declaredName) {
      Stop-Install "skill missing name in frontmatter: $skillMarkdown"
    }
    if ($declaredName -ne $skillName) {
      Stop-Install "skill name mismatch for ${skillName}: frontmatter name is $declaredName"
    }

    $found += $skillName
  }

  if ($found.Count -eq 0) {
    Stop-Install "no installable skills were discovered in: $SourceRoot"
  }

  return $found
}

function Join-UserPath {
  param(
    [string]$Root,
    [string]$Child
  )
  return (Join-Path $Root $Child)
}

$UserProfile = [Environment]::GetFolderPath('UserProfile')
if ([string]::IsNullOrWhiteSpace($UserProfile)) {
  $UserProfile = $env:USERPROFILE
}
if ([string]::IsNullOrWhiteSpace($UserProfile)) {
  Stop-Install 'cannot determine the current Windows user profile directory'
}

$AppData = [Environment]::GetFolderPath('ApplicationData')
if ([string]::IsNullOrWhiteSpace($AppData)) {
  $AppData = Join-Path $UserProfile 'AppData\Roaming'
}

$script:ToolSpecs = @(
  [pscustomobject]@{ Key = 'claude_code'; Display = 'Claude Code'; DetectDirs = @((Join-UserPath $UserProfile '.claude')); TargetDirs = @((Join-UserPath $UserProfile '.claude\skills')); Support = 'verified' },
  [pscustomobject]@{ Key = 'codex'; Display = 'Codex'; DetectDirs = @((Join-UserPath $UserProfile '.codex')); TargetDirs = @((Join-UserPath $UserProfile '.codex\skills')); Support = 'verified' },
  [pscustomobject]@{ Key = 'openclaw'; Display = 'OpenClaw'; DetectDirs = @((Join-UserPath $UserProfile '.openclaw')); TargetDirs = @((Join-UserPath $UserProfile '.openclaw\skills')); Support = 'verified' },
  [pscustomobject]@{ Key = 'cursor'; Display = 'Cursor'; DetectDirs = @((Join-UserPath $UserProfile '.cursor')); TargetDirs = @((Join-UserPath $UserProfile '.cursor\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'antigravity'; Display = 'Antigravity'; DetectDirs = @((Join-UserPath $UserProfile '.gemini\antigravity')); TargetDirs = @((Join-UserPath $UserProfile '.gemini\antigravity\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'openclaude'; Display = 'OpenClaude'; DetectDirs = @((Join-UserPath $UserProfile '.openclaude')); TargetDirs = @((Join-UserPath $UserProfile '.openclaude\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'opencode'; Display = 'OpenCode'; DetectDirs = @((Join-Path $AppData 'opencode'), (Join-UserPath $UserProfile '.config\opencode')); TargetDirs = @((Join-Path $AppData 'opencode\skills'), (Join-UserPath $UserProfile '.config\opencode\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'continue'; Display = 'Continue'; DetectDirs = @((Join-UserPath $UserProfile '.continue')); TargetDirs = @((Join-UserPath $UserProfile '.continue\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'gemini_cli'; Display = 'Gemini CLI'; DetectDirs = @((Join-UserPath $UserProfile '.gemini')); TargetDirs = @((Join-UserPath $UserProfile '.gemini\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'github_copilot'; Display = 'GitHub Copilot'; DetectDirs = @((Join-UserPath $UserProfile '.copilot')); TargetDirs = @((Join-UserPath $UserProfile '.copilot\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'qwen_code'; Display = 'Qwen Code'; DetectDirs = @((Join-UserPath $UserProfile '.qwen')); TargetDirs = @((Join-UserPath $UserProfile '.qwen\skills')); Support = 'best-effort' },
  [pscustomobject]@{ Key = 'windsurf'; Display = 'Windsurf'; DetectDirs = @((Join-UserPath $UserProfile '.codeium\windsurf')); TargetDirs = @((Join-UserPath $UserProfile '.codeium\windsurf\skills')); Support = 'best-effort' }
)

function Test-ToolSelected {
  param([string]$Key)
  if ($script:Tool.Count -eq 0) {
    return $true
  }
  return ($script:Tool -contains $Key)
}

function Validate-SelectedTools {
  $knownKeys = @($script:ToolSpecs | ForEach-Object { $_.Key })
  foreach ($selected in $script:Tool) {
    if ($knownKeys -notcontains $selected) {
      Stop-Install "unknown tool key: $selected. Supported keys: $($knownKeys -join ', ')"
    }
  }
}

function Get-DetectedTargets {
  $detected = @()

  foreach ($spec in $script:ToolSpecs) {
    if (-not (Test-ToolSelected -Key $spec.Key)) {
      continue
    }

    for ($i = 0; $i -lt $spec.DetectDirs.Count; $i++) {
      $detectDir = $spec.DetectDirs[$i]
      if (Test-Path -LiteralPath $detectDir -PathType Container) {
        $detected += [pscustomobject]@{
          Key = $spec.Key
          Display = $spec.Display
          DetectDir = $detectDir
          TargetDir = $spec.TargetDirs[$i]
          Support = $spec.Support
        }
        break
      }
    }
  }

  return $detected
}

function Backup-IfExists {
  param(
    [string]$SkillTarget,
    [string]$TargetDir,
    [string]$ToolKey,
    [string]$Timestamp
  )

  if (-not (Test-Path -LiteralPath $SkillTarget)) {
    return
  }

  $toolRoot = Split-Path -Parent $TargetDir
  $backupRoot = Join-Path $toolRoot (Join-Path '.dropshippinglite-agent-skills-backups' (Join-Path $ToolKey $Timestamp))
  $backupTarget = Join-Path $backupRoot (Split-Path -Leaf $SkillTarget)

  if ($script:DryRun) {
    Write-Host "DRY RUN: backup $(Split-Path -Leaf $SkillTarget) -> $backupTarget"
    return
  }

  New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
  Move-Item -LiteralPath $SkillTarget -Destination $backupTarget -Force
}

function Install-SkillsToTarget {
  param(
    [string]$SourceRoot,
    [pscustomobject]$Target,
    [string]$Timestamp,
    [string[]]$SkillNames
  )

  if ($script:DryRun) {
    Write-Info "DRY RUN  $($Target.Display) [$($Target.Support)]"
    Write-Host "         target: $($Target.TargetDir)"
  } else {
    New-Item -ItemType Directory -Path $Target.TargetDir -Force | Out-Null
    if ($Target.Support -eq 'verified') {
      Write-Info "✓ Installed into $($Target.Display)"
    } else {
      Write-Info "○ Installed into $($Target.Display) (best effort)"
    }
  }

  foreach ($skill in $SkillNames) {
    $sourceSkill = Join-Path $SourceRoot $skill
    $targetSkill = Join-Path $Target.TargetDir $skill

    Backup-IfExists -SkillTarget $targetSkill -TargetDir $Target.TargetDir -ToolKey $Target.Key -Timestamp $Timestamp

    if ($script:DryRun) {
      Write-Host "         - copy $skill"
      continue
    }

    Copy-Item -LiteralPath $sourceSkill -Destination $Target.TargetDir -Recurse -Force
  }
}

Validate-SelectedTools

$SourceRoot = Get-SkillSourceRoot
$SkillNames = @(Get-InstallableSkills -SourceRoot $SourceRoot)
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DetectedTargets = @(Get-DetectedTargets)

if ($DetectedTargets.Count -eq 0) {
  Stop-Install 'no supported AI tools were detected in this account. Install a supported tool first or rerun with a different account.'
}

Write-Section 'NS Client Agent Skills Installer'
if ($script:DryRun) {
  Write-Host 'Mode            -> dry run'
  Write-Host "Repository      -> $($script:RepoOwner)/$($script:RepoName)"
  Write-Host "Release ref     -> $($script:Ref)"
  Write-Host "Skill source    -> $SourceRoot"
  Write-Host "Skills found    -> $($SkillNames.Count)"
  foreach ($skill in $SkillNames) {
    Write-Host "  - $skill"
  }
  Write-Host "Detected AI tools  -> $($DetectedTargets.Count)"
  Write-Section 'Detected Targets'
  foreach ($target in $DetectedTargets) {
    Write-Host "- $($target.Display) [$($target.Support)]"
    Write-Host "    detect: $($target.DetectDir)"
    Write-Host "    target: $($target.TargetDir)"
  }
} else {
  Write-Host "Skills in pack  -> $($SkillNames.Count)"
  Write-Host "Detected AI tools  -> $($DetectedTargets.Count)"
  Write-Section 'Installing Into'
  foreach ($target in $DetectedTargets) {
    if ($target.Support -eq 'verified') {
      Write-Host "✓ $($target.Display)"
    } else {
      Write-Host "○ $($target.Display) (best effort)"
    }
  }
}

foreach ($target in $DetectedTargets) {
  Install-SkillsToTarget -SourceRoot $SourceRoot -Target $target -Timestamp $Timestamp -SkillNames $SkillNames
}

Write-Section 'Result'
if ($script:DryRun) {
  Write-Success 'Dry run complete. No files were changed.'
} else {
  Write-Success 'Installation complete.'
  Write-Section 'Next Steps'
  Write-Host '1. Open your preferred AI tool.'
  Write-Host '2. Ask a normal NS Client business question in natural language.'
  Write-Host '3. If credentials are not configured yet,'
  Write-Host '   let the AI tool prompt you for Base URL, access_key_id, and secret.'
  Write-Host '4. Approve local credential saving if you want future reuse.'
}
