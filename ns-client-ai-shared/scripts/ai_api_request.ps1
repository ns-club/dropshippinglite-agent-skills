$ErrorActionPreference = 'Stop'

function Get-UserConfigPath {
  if ($env:OS -eq 'Windows_NT') {
    return (Join-Path $HOME '.ns-client\ai-api.json')
  }
  return (Join-Path $HOME '.config/ns-client/ai-api.json')
}

function Get-RepoConfigPath {
  $current = (Get-Location).Path
  while ($true) {
    if ((Test-Path -LiteralPath (Join-Path $current '.ns-client-ai.local.json')) -or (Test-Path -LiteralPath (Join-Path $current '.git'))) {
      return (Join-Path $current '.ns-client-ai.local.json')
    }
    $parent = Split-Path -Parent $current
    if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $current) {
      return (Join-Path (Get-Location).Path '.ns-client-ai.local.json')
    }
    $current = $parent
  }
}

function Get-ConfigPaths {
  $paths = New-Object System.Collections.Generic.List[object]
  if (-not [string]::IsNullOrWhiteSpace($env:NS_CLIENT_AI_CONFIG)) {
    $paths.Add([pscustomobject]@{ Label = 'NS_CLIENT_AI_CONFIG'; Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($env:NS_CLIENT_AI_CONFIG) })
  }
  $paths.Add([pscustomobject]@{ Label = 'repo'; Path = Get-RepoConfigPath })
  $paths.Add([pscustomobject]@{ Label = 'user'; Path = Get-UserConfigPath })
  return $paths
}

function Read-JsonConfig($Path) {
  $result = @{}
  if (-not (Test-Path -LiteralPath $Path)) { return $result }
  $data = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  foreach ($entry in @(
    @{ Key = 'base_url'; Aliases = @('base_url', 'NS_CLIENT_AI_BASE_URL') },
    @{ Key = 'access_key_id'; Aliases = @('access_key_id', 'NS_CLIENT_AI_ACCESS_KEY_ID') },
    @{ Key = 'secret'; Aliases = @('secret', 'NS_CLIENT_AI_SECRET') }
  )) {
    foreach ($alias in $entry.Aliases) {
      if ($data.PSObject.Properties.Name -contains $alias) {
        $value = [string]$data.$alias
        if (-not [string]::IsNullOrWhiteSpace($value)) {
          $result[$entry.Key] = $value.Trim()
          break
        }
      }
    }
  }
  return $result
}

function Resolve-Credentials {
  $credentials = @{}
  $sources = @{}
  $envMap = @{
    base_url = 'NS_CLIENT_AI_BASE_URL'
    access_key_id = 'NS_CLIENT_AI_ACCESS_KEY_ID'
    secret = 'NS_CLIENT_AI_SECRET'
  }

  foreach ($key in $envMap.Keys) {
    $value = [Environment]::GetEnvironmentVariable($envMap[$key], 'Process')
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      $credentials[$key] = $value.Trim()
      $sources[$key] = "env:$($envMap[$key])"
    }
  }

  foreach ($item in Get-ConfigPaths) {
    $fileValues = Read-JsonConfig $item.Path
    foreach ($key in @('base_url', 'access_key_id', 'secret')) {
      if (-not $credentials.ContainsKey($key) -and $fileValues.ContainsKey($key)) {
        $credentials[$key] = $fileValues[$key]
        $sources[$key] = "config:$($item.Label):$($item.Path)"
      }
    }
  }

  $missing = @('base_url', 'access_key_id', 'secret') | Where-Object { -not $credentials.ContainsKey($_) -or [string]::IsNullOrWhiteSpace($credentials[$_]) }
  return [pscustomobject]@{ Credentials = $credentials; Sources = $sources; Missing = @($missing) }
}

function Write-Status {
  $resolved = Resolve-Credentials
  $paths = @(Get-ConfigPaths | ForEach-Object { [pscustomobject]@{ label = $_.Label; path = $_.Path; exists = (Test-Path -LiteralPath $_.Path) } })
  [pscustomobject]@{
    resolved = ($resolved.Missing.Count -eq 0)
    missing = @($resolved.Missing)
    sources = [pscustomobject]$resolved.Sources
    config_paths = $paths
  } | ConvertTo-Json -Depth 5
}

function Get-TargetConfigPath($Scope, $Config) {
  if (-not [string]::IsNullOrWhiteSpace($Config)) {
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Config)
  }
  if ($Scope -eq 'repo') { return Get-RepoConfigPath }
  return Get-UserConfigPath
}

function Save-ConfigFromEnv($RestArgs) {
  $scope = 'user'
  $config = $null
  for ($i = 0; $i -lt $RestArgs.Count; $i++) {
    switch ($RestArgs[$i]) {
      '--scope' { $i++; $scope = $RestArgs[$i] }
      '--config' { $i++; $config = $RestArgs[$i] }
      default { throw "Unknown argument: $($RestArgs[$i])" }
    }
  }
  if ($scope -notin @('user', 'repo')) { throw 'Scope must be user or repo' }

  $values = [ordered]@{
    base_url = $env:NS_CLIENT_AI_BASE_URL
    access_key_id = $env:NS_CLIENT_AI_ACCESS_KEY_ID
    secret = $env:NS_CLIENT_AI_SECRET
  }
  $missing = $values.Keys | Where-Object { [string]::IsNullOrWhiteSpace($values[$_]) }
  if ($missing.Count -gt 0) { throw "Missing environment values: $($missing -join ', ')" }

  $path = Get-TargetConfigPath $scope $config
  $parent = Split-Path -Parent $path
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  $values | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding UTF8
  [pscustomobject]@{ saved = $true; path = $path; scope = $scope } | ConvertTo-Json
}

function Read-ErrorBody($Response) {
  if ($null -eq $Response) { return '' }
  if ($Response.Content -and $Response.Content.GetType().FullName -like 'System.Net.Http*') {
    return $Response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
  }
  try {
    $stream = $Response.GetResponseStream()
    if ($null -eq $stream) { return '' }
    $reader = New-Object System.IO.StreamReader($stream)
    return $reader.ReadToEnd()
  } catch {
    return ''
  }
}

function Get-RetryAfter($Response) {
  if ($null -eq $Response) { return $null }
  try {
    if ($Response.Headers['Retry-After']) { return [double]$Response.Headers['Retry-After'] }
  } catch {}
  return $null
}

function Invoke-AiRequest($RestArgs) {
  if ($RestArgs.Count -lt 1) { throw 'Missing endpoint' }
  $endpoint = $RestArgs[0]
  if (-not $endpoint.StartsWith('/api/ai/v1/')) { throw 'Endpoint must start with /api/ai/v1/' }

  $timeout = 30
  $query = New-Object System.Collections.Generic.List[string]
  for ($i = 1; $i -lt $RestArgs.Count; $i++) {
    switch ($RestArgs[$i]) {
      '--param' { $i++; $query.Add($RestArgs[$i]) }
      '--timeout' { $i++; $timeout = [int]$RestArgs[$i] }
      default { throw "Unknown argument: $($RestArgs[$i])" }
    }
  }

  $resolved = Resolve-Credentials
  if ($resolved.Missing.Count -gt 0) {
    $errorJson = [pscustomobject]@{ error = 'missing_credentials'; missing = @($resolved.Missing) } | ConvertTo-Json -Compress
    [Console]::Error.WriteLine($errorJson)
    exit 2
  }

  $baseUrl = ([string]$resolved.Credentials['base_url']).TrimEnd('/')
  $uriBuilder = [System.UriBuilder]::new($baseUrl + $endpoint)
  $pairs = New-Object System.Collections.Generic.List[string]
  foreach ($item in $query) {
    $parts = $item.Split('=', 2)
    if ($parts.Count -ne 2 -or [string]::IsNullOrWhiteSpace($parts[0])) { throw "Invalid --param value, expected key=value: $item" }
    $pairs.Add("$([System.Uri]::EscapeDataString($parts[0]))=$([System.Uri]::EscapeDataString($parts[1]))")
  }
  if ($pairs.Count -gt 0) { $uriBuilder.Query = ($pairs -join '&') }

  $headers = @{
    Authorization = "Bearer $($resolved.Credentials['access_key_id']).$($resolved.Credentials['secret'])"
    Accept = 'application/json'
  }
  $invokeArgs = @{ Uri = $uriBuilder.Uri.AbsoluteUri; Headers = $headers; Method = 'GET'; TimeoutSec = $timeout; ErrorAction = 'Stop' }
  if ($PSVersionTable.PSVersion.Major -lt 6) { $invokeArgs['UseBasicParsing'] = $true }

  for ($attempt = 0; $attempt -lt 2; $attempt++) {
    try {
      $response = Invoke-WebRequest @invokeArgs
      Write-Output $response.Content
      return
    } catch {
      $response = $_.Exception.Response
      $status = $null
      try { $status = [int]$response.StatusCode } catch {}
      $retryAfter = Get-RetryAfter $response
      if ($status -eq 429 -and $attempt -eq 0 -and $retryAfter) {
        Start-Sleep -Seconds ([Math]::Min($retryAfter, 60))
        continue
      }
      $body = Read-ErrorBody $response
      if (-not [string]::IsNullOrWhiteSpace($body)) {
        [Console]::Error.WriteLine($body)
      } else {
        $errorJson = [pscustomobject]@{ error = 'http_error'; status = $status } | ConvertTo-Json -Compress
        [Console]::Error.WriteLine($errorJson)
      }
      exit 1
    }
  }
}

if ($args.Count -lt 1 -or $args[0] -in @('-h', '--help', 'help')) {
  @'
Usage:
  ai_api_request.ps1 status
  ai_api_request.ps1 set-from-env [--scope user|repo] [--config path]
  ai_api_request.ps1 request /api/ai/v1/orders --param page=1 --param per_page=50 [--timeout 30]
'@
  exit 0
}

$command = $args[0]
$restArgs = @($args | Select-Object -Skip 1)
switch ($command) {
  'status' { Write-Status }
  'set-from-env' { Save-ConfigFromEnv $restArgs }
  'request' { Invoke-AiRequest $restArgs }
  default { throw "Unknown command: $command" }
}