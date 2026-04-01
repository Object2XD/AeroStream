param(
  [Parameter(Mandatory = $true)]
  [string]$OAuthJsonPath,

  [ValidateSet('run', 'build')]
  [string]$Action = 'run',

  [ValidateSet('debug', 'profile', 'release')]
  [string]$Mode = 'debug',

  [switch]$ConfigOnly,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ExtraFlutterArgs
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent
$defineFile = Join-Path $repoRoot 'build_config\google_drive_oauth.env.json'

Push-Location $repoRoot
try {
  & dart run tool/prepare_google_drive_oauth.dart `
    --input $OAuthJsonPath `
    --output $defineFile `
    --flutter-hint "$Action windows"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }

  $flutterArgs = @()
  if ($Action -eq 'run') {
    $flutterArgs += @('run', '-d', 'windows')
  } else {
    $flutterArgs += @('build', 'windows')
  }

  switch ($Mode) {
    'debug' {
      $flutterArgs += '--debug'
    }
    'profile' {
      $flutterArgs += '--profile'
    }
    'release' {
      $flutterArgs += '--release'
    }
  }

  $flutterArgs += "--dart-define-from-file=$defineFile"
  if ($ConfigOnly) {
    $flutterArgs += '--config-only'
  }
  if ($ExtraFlutterArgs) {
    $flutterArgs += $ExtraFlutterArgs
  }

  & flutter @flutterArgs
  exit $LASTEXITCODE
} finally {
  Pop-Location
}
