# run-tests.ps1 — test-run スキル用のテスト実行ヘルパ (PowerShell 版)
#
# 使い方:
#   pwsh run-tests.ps1 `
#     -ProjectRoot <path> `
#     -Phase <test-implementation|implementation> `
#     -Mode <red|green> `
#     -Target <FID> `
#     [-Layers "unit,integration,e2e"]
#
# exit code:
#   0   — verdict=PASS (期待通り)
#   10  — verdict=FAIL
#   2   — 引数 / 設定エラー

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ProjectRoot,
  [Parameter(Mandatory = $true)][string]$Phase,
  [Parameter(Mandatory = $true)][ValidateSet("red", "green")][string]$Mode,
  [Parameter(Mandatory = $true)][string]$Target,
  [string]$Layers = "unit,integration,e2e"
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StackCfg = Join-Path $ProjectRoot ".dev-workflow/rules/stack/stack-config.md"
$ProjectCfg = Join-Path $ProjectRoot ".dev-workflow/rules/project/stack-config.md"

if (-not (Test-Path $StackCfg)) {
  Write-Error "stack-config.md not found at $StackCfg"
  exit 2
}

$OutDir = Join-Path $ProjectRoot "docs/04_test_results/$Target"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Log = Join-Path $OutDir "$Phase-$Mode-run.log"
$Report = Join-Path $OutDir "$Phase-$Mode-confirmation.md"

$StartAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

function Extract-Command([string]$Layer) {
  $args = @("--mode", "extract-command", "--stack", $StackCfg, "--layer", $Layer, "--fid", $Target)
  if (Test-Path $ProjectCfg) { $args = @("--project", $ProjectCfg) + $args }
  $output = & python3 (Join-Path $ScriptDir "parse-results.py") @args
  return $output
}

function Parse-Output([string]$LayerName, [string]$Text) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp.FullName -Value $Text -Encoding utf8
  $result = & python3 (Join-Path $ScriptDir "parse-results.py") --mode parse-output --layer $LayerName < $tmp.FullName
  Remove-Item $tmp.FullName -Force
  $parts = $result -split '\s+'
  return [pscustomobject]@{
    total = [int]$parts[0]; pass = [int]$parts[1]; fail = [int]$parts[2];
    skip = [int]$parts[3]; xfail = [int]$parts[4]
  }
}

$LayerArr = $Layers -split ','
$Results = @{}
$LogContent = ""

foreach ($layer in $LayerArr) {
  $cmd = Extract-Command $layer
  if (-not $cmd) {
    $Results[$layer] = [pscustomobject]@{
      total = 0; pass = 0; fail = 0; skip = 0; xfail = 0
      exit_code = "-"; duration = 0
      command = "(no command defined for $layer in stack-config.md)"
      output = ""
    }
    continue
  }
  $started = Get-Date
  $tmp = New-TemporaryFile
  Push-Location $ProjectRoot
  cmd /c $cmd > $tmp.FullName 2>&1
  $code = $LASTEXITCODE
  Pop-Location
  $duration = [int]((Get-Date) - $started).TotalSeconds
  $output = Get-Content $tmp.FullName -Raw -ErrorAction SilentlyContinue
  $head = ($output -split "`n" | Select-Object -First 100) -join "`n"
  $LogContent += $output + "`n"
  $parsed = Parse-Output $layer $output
  Remove-Item $tmp.FullName -Force -ErrorAction SilentlyContinue
  $Results[$layer] = [pscustomobject]@{
    total = $parsed.total; pass = $parsed.pass; fail = $parsed.fail
    skip = $parsed.skip; xfail = $parsed.xfail
    exit_code = $code; duration = $duration
    command = $cmd; output = $head
  }
}

Set-Content -Path $Log -Value $LogContent -Encoding utf8

# Aggregate
$Total = ($Results.Values | Measure-Object -Property total -Sum).Sum
$Pass  = ($Results.Values | Measure-Object -Property pass  -Sum).Sum
$Fail  = ($Results.Values | Measure-Object -Property fail  -Sum).Sum
$Skip  = ($Results.Values | Measure-Object -Property skip  -Sum).Sum
$Xfail = ($Results.Values | Measure-Object -Property xfail -Sum).Sum

$Verdict = "FAIL"
if ($Mode -eq "red") {
  if ($Fail -gt 0 -and $Pass -eq 0) { $Verdict = "PASS" }
  $ExpectedText = "全テスト Fail (Red)"
} else {
  if ($Fail -eq 0 -and $Pass -gt 0) { $Verdict = "PASS" }
  $ExpectedText = "全テスト Pass (Green)"
}
$ObservedText = "executed=$Total pass=$Pass fail=$Fail skip=$Skip xfail=$Xfail"

# Build report
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# $Phase — $Mode 確認 (test-run)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("実行日時: $StartAt")
[void]$sb.AppendLine("対象機能: $Target")
[void]$sb.AppendLine("モード: $Mode")
[void]$sb.AppendLine("プロジェクトルート: $ProjectRoot")
[void]$sb.AppendLine("実行環境: PowerShell $($PSVersionTable.PSVersion) / Windows")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## サマリ")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 層           | 実行 | pass | fail | skip | xfail | 判定 |")
[void]$sb.AppendLine("|--------------|------|------|------|------|-------|------|")
foreach ($layer in $LayerArr) {
  $r = $Results[$layer]
  [void]$sb.AppendLine("| $layer | $($r.total) | $($r.pass) | $($r.fail) | $($r.skip) | $($r.xfail) | - |")
}
[void]$sb.AppendLine("| **合計** | $Total | $Pass | $Fail | $Skip | $Xfail | **$Verdict** |")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("期待: $ExpectedText")
[void]$sb.AppendLine("実際: $ObservedText")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("**判定: $Verdict**")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 各層の実行コマンドと出力")
[void]$sb.AppendLine("")
foreach ($layer in $LayerArr) {
  $r = $Results[$layer]
  [void]$sb.AppendLine("### $layer")
  [void]$sb.AppendLine("- コマンド: ``$($r.command)``")
  [void]$sb.AppendLine("- exit code: $($r.exit_code)")
  [void]$sb.AppendLine("- 実行時間: $($r.duration)s")
  [void]$sb.AppendLine("- 出力 (先頭 100 行):")
  [void]$sb.AppendLine("")
  [void]$sb.AppendLine('```')
  [void]$sb.AppendLine($r.output)
  [void]$sb.AppendLine('```')
  [void]$sb.AppendLine("")
}

$sb.ToString() | Set-Content -Path $Report -Encoding utf8

Write-Host "AUTO_RUN_SUMMARY phase=$Phase mode=$Mode target=$Target"
Write-Host "  total=$Total pass=$Pass fail=$Fail skip=$Skip xfail=$Xfail"
Write-Host "  verdict=$Verdict"
Write-Host "  report=$Report"
Write-Host "  log=$Log"

if ($Verdict -eq "FAIL") { exit 10 }
exit 0
