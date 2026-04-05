param(
  [ValidateSet('run', 'build')]
  [string]$Action = 'run',

  [ValidateSet('debug', 'profile', 'release')]
  [string]$FlutterMode = 'debug',

  [string]$DefineFile = '',

  [switch]$ConfigOnly,

  [string[]]$BenchmarkArgs = @()
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent
$benchmarkTarget = 'lib/drive_benchmark_main.dart'
$restoreTarget = 'lib/main.dart'

if ([string]::IsNullOrWhiteSpace($DefineFile)) {
  $DefineFile = Join-Path $repoRoot 'build_config\google_drive_oauth.env.json'
}

if (-not (Test-Path $DefineFile)) {
  throw "OAuth define file not found: $DefineFile"
}

if ($BenchmarkArgs.Count -gt 0 -and $BenchmarkArgs[0] -eq '--') {
  $BenchmarkArgs = @($BenchmarkArgs | Select-Object -Skip 1)
}

if ($Action -eq 'run' -and $ConfigOnly) {
  throw 'ConfigOnly is not supported with -Action run.'
}

if ($Action -eq 'build' -and $BenchmarkArgs.Count -gt 0) {
  throw 'Benchmark runtime args are only supported with -Action run.'
}

Push-Location $repoRoot
try {
  $benchmarkExitCode = 0
  $needsDebugRestore = $benchmarkTarget -ne $restoreTarget

  $flutterArgs = @()
  $flutterArgs += @('build', 'windows')

  switch ($FlutterMode) {
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

  $flutterArgs += "--dart-define-from-file=$DefineFile"
  $flutterArgs += @('-t', $benchmarkTarget)

  if ($ConfigOnly) {
    $flutterArgs += '--config-only'
  }

  & flutter @flutterArgs
  if ($LASTEXITCODE -ne 0) {
    $benchmarkExitCode = $LASTEXITCODE
    exit $benchmarkExitCode
  }

  if ($Action -eq 'build') {
    exit 0
  }

  $configurationDir = switch ($FlutterMode) {
    'debug' { 'Debug' }
    'profile' { 'Profile' }
    'release' { 'Release' }
  }
  $exePath = Join-Path $repoRoot "build\\windows\\x64\\runner\\$configurationDir\\aero_stream.exe"
  if (-not (Test-Path $exePath)) {
    throw "Benchmark executable not found: $exePath"
  }

  $argumentLine = (($BenchmarkArgs | ForEach-Object {
    if ($_ -match '[\s"]') {
      '"' + $_.Replace('"', '\"') + '"'
    } else {
      $_
    }
  }) -join ' ')

  $stdoutPath = Join-Path ([System.IO.Path]::GetTempPath()) ("aero-benchmark-stdout-" + [guid]::NewGuid().ToString('N') + '.log')
  $stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) ("aero-benchmark-stderr-" + [guid]::NewGuid().ToString('N') + '.log')
  try {
    $process = Start-Process `
      -FilePath $exePath `
      -ArgumentList $argumentLine `
      -Wait `
      -PassThru `
      -NoNewWindow `
      -RedirectStandardOutput $stdoutPath `
      -RedirectStandardError $stderrPath

    if (Test-Path $stdoutPath) {
      Get-Content $stdoutPath
    }
    if (Test-Path $stderrPath) {
      $stderr = Get-Content $stderrPath
      if ($stderr) {
        $stderr | ForEach-Object { Write-Error $_ }
      }
    }

    $benchmarkExitCode = $process.ExitCode
    exit $benchmarkExitCode
  } finally {
    Remove-Item $stdoutPath,$stderrPath -ErrorAction SilentlyContinue
  }
} finally {
  if ($needsDebugRestore) {
    Write-Host 'Restoring default Debug Windows app build for lib/main.dart...'
    $restoreArgs = @(
      'build',
      'windows',
      '--debug',
      "--dart-define-from-file=$DefineFile",
      '-t',
      $restoreTarget
    )
    & flutter @restoreArgs
    if ($LASTEXITCODE -ne 0) {
      Write-Warning 'Failed to restore the default Debug Windows app build. Run "flutter build windows --debug -t lib/main.dart" before the next flutter run.'
    }
  }
  Pop-Location
}
