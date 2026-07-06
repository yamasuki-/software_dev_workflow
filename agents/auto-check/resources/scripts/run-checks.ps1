# run-checks.ps1 — auto-check の本体ランナー (PowerShell 版)
#
# 使い方:
#   pwsh run-checks.ps1 `
#     -ProjectRoot <path> `
#     -Phase <basic-design|...> `
#     [-Mode per_feature|cross] `
#     [-Target <FID|ALL>] `
#     [-Out <report.md>]
#
# exit code:
#   0   — MUST 全 pass
#   10  — MUST fail あり
#   2   — 引数 / 設定エラー

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ProjectRoot,
  [Parameter(Mandatory = $true)][string]$Phase,
  [string]$Mode = "per_feature",
  [string]$Target = "ALL",
  [string]$Out = ""
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StackCfg = Join-Path $ProjectRoot ".dev-workflow/rules/stack/stack-config.md"
$ProjectCfg = Join-Path $ProjectRoot ".dev-workflow/rules/project/stack-config.md"

if (-not (Test-Path $StackCfg)) {
  Write-Error "stack-config.md not found at $StackCfg"
  exit 2
}

$parseArgs = @("--stack", $StackCfg, "--phase", $Phase)
if (Test-Path $ProjectCfg) {
  $parseArgs = @("--project", $ProjectCfg) + $parseArgs
}

$parsedJson = & python3 (Join-Path $ScriptDir "parse-stack-config.py") @parseArgs
if ($LASTEXITCODE -ne 0) {
  Write-Error "parse-stack-config.py failed"
  exit 2
}
$parsed = $parsedJson | ConvertFrom-Json

if (-not $Out) {
  if ($Mode -eq "cross") {
    $OutDir = Join-Path $ProjectRoot "docs/06_reviews/_cross"
  } else {
    $OutDir = Join-Path $ProjectRoot "docs/06_reviews/$Target"
  }
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  $Out = Join-Path $OutDir "$Phase-auto-check.md"
}

$StartAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$Results = @()

function Invoke-Tier {
  param([string]$Tier, [object[]]$Items)
  foreach ($it in $Items) {
    $cmd = $it.command
    $name = $it.name
    $hint = $it.install_hint
    $first = ($cmd -split '\s+')[0]
    $exists = Get-Command $first -ErrorAction SilentlyContinue
    if (-not $exists) {
      $script:Results += [pscustomobject]@{
        tier = $Tier; name = $name; status = "SKIPPED_MISSING";
        exit_code = $null; duration_sec = 0; snippet = ""; install_hint = $hint; cmd = $cmd
      }
      continue
    }
    $started = Get-Date
    $tmp = New-TemporaryFile
    cmd /c $cmd > $tmp.FullName 2>&1
    $code = $LASTEXITCODE
    $duration = [int]((Get-Date) - $started).TotalSeconds
    $output = (Get-Content $tmp.FullName -TotalCount 50 -ErrorAction SilentlyContinue) -join "`n"
    Remove-Item $tmp.FullName -Force -ErrorAction SilentlyContinue
    $status = if ($code -eq 0) { "PASS" } else { "FAIL" }
    $script:Results += [pscustomobject]@{
      tier = $Tier; name = $name; status = $status;
      exit_code = $code; duration_sec = $duration; snippet = $output; install_hint = $hint; cmd = $cmd
    }
  }
}

Invoke-Tier "MUST"   $parsed.must
Invoke-Tier "SHOULD" $parsed.should
Invoke-Tier "MAY"    $parsed.may

function CountStatus([string]$tier, [string]$status) {
  ($Results | Where-Object { $_.tier -eq $tier -and $_.status -eq $status }).Count
}
function TotalOfTier([string]$tier) {
  ($Results | Where-Object { $_.tier -eq $tier }).Count
}
$MUST_T = TotalOfTier "MUST"; $MUST_P = CountStatus "MUST" "PASS"; $MUST_F = CountStatus "MUST" "FAIL"; $MUST_S = CountStatus "MUST" "SKIPPED_MISSING"
$SHOULD_T = TotalOfTier "SHOULD"; $SHOULD_P = CountStatus "SHOULD" "PASS"; $SHOULD_F = CountStatus "SHOULD" "FAIL"; $SHOULD_S = CountStatus "SHOULD" "SKIPPED_MISSING"
$MAY_T = TotalOfTier "MAY"; $MAY_P = CountStatus "MAY" "PASS"; $MAY_F = CountStatus "MAY" "FAIL"; $MAY_S = CountStatus "MAY" "SKIPPED_MISSING"

$Verdict = if ($MUST_F -gt 0) { "FAIL (MUST 失敗あり)" } else { "PASS" }

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# $Phase — auto-check 結果")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("実行日時: $StartAt")
[void]$sb.AppendLine("対象モード: $Mode")
[void]$sb.AppendLine("対象機能: $Target")
[void]$sb.AppendLine("プロジェクトルート: $ProjectRoot")
[void]$sb.AppendLine("実行環境: PowerShell $(($PSVersionTable.PSVersion).ToString()) / Windows")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## サマリ")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 階層   | 実行 | pass | fail | skipped (missing) |")
[void]$sb.AppendLine("|--------|------|------|------|-------------------|")
[void]$sb.AppendLine("| MUST   | $MUST_T | $MUST_P | $MUST_F | $MUST_S |")
[void]$sb.AppendLine("| SHOULD | $SHOULD_T | $SHOULD_P | $SHOULD_F | $SHOULD_S |")
[void]$sb.AppendLine("| MAY    | $MAY_T | $MAY_P | $MAY_F | $MAY_S |")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("**判定: $Verdict**")
[void]$sb.AppendLine("")

foreach ($tier in @("MUST", "SHOULD", "MAY")) {
  [void]$sb.AppendLine("## $tier 詳細")
  [void]$sb.AppendLine("")
  foreach ($r in ($Results | Where-Object { $_.tier -eq $tier })) {
    if ($r.status -eq "SKIPPED_MISSING") {
      [void]$sb.AppendLine("### $($r.name)")
      [void]$sb.AppendLine("- status: SKIPPED (tool not installed)")
      [void]$sb.AppendLine("- install hint: ``$($r.install_hint)``")
      [void]$sb.AppendLine("")
      continue
    }
    [void]$sb.AppendLine("### $($r.name)")
    [void]$sb.AppendLine("- コマンド: ``$($r.cmd)``")
    [void]$sb.AppendLine("- exit code: $($r.exit_code)")
    [void]$sb.AppendLine("- 実行時間: $($r.duration_sec)s")
    [void]$sb.AppendLine("- 出力 (先頭 50 行):")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine($r.snippet)
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine("")
  }
}

$sb.ToString() | Set-Content -Path $Out -Encoding utf8

Write-Host "AUTO_CHECK_SUMMARY phase=$Phase mode=$Mode target=$Target"
Write-Host "  MUST   total=$MUST_T pass=$MUST_P fail=$MUST_F skipped=$MUST_S"
Write-Host "  SHOULD total=$SHOULD_T pass=$SHOULD_P fail=$SHOULD_F skipped=$SHOULD_S"
Write-Host "  MAY    total=$MAY_T pass=$MAY_P fail=$MAY_F skipped=$MAY_S"
Write-Host "  verdict=$Verdict"
Write-Host "  report=$Out"

if ($MUST_F -gt 0) { exit 10 }
exit 0
