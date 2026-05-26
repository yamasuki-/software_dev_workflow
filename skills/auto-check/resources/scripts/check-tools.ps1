# check-tools.ps1 — 指定されたツール群がインストールされているか確認する (PowerShell 版)
#
# 使い方:
#   pwsh check-tools.ps1 markdownlint-cli2 mmdc textlint typos lychee
#
# 出力 (1 行 1 ツール、TAB 区切り):
#   <tool>\tOK\t<version>
#   <tool>\tMISSING\t-

param(
  [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
  [string[]]$Tools
)

function Probe([string]$Tool) {
  $cmd = Get-Command $Tool -ErrorAction SilentlyContinue
  if (-not $cmd) {
    "$Tool`tMISSING`t-"
    return
  }
  $ver = ""
  try {
    $output = & $Tool --version 2>&1
    if ($LASTEXITCODE -ne 0) { $output = "" }
    $ver = ($output -split "`n" | Select-Object -First 1).Trim()
  } catch {
    $ver = "(version unknown)"
  }
  if (-not $ver) { $ver = "(version unknown)" }
  "$Tool`tOK`t$ver"
}

foreach ($t in $Tools) {
  Probe $t
}
