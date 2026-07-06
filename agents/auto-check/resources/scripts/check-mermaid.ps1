# check-mermaid.ps1 — Markdown ファイル内の Mermaid ブロックを抽出して mmdc でパース検証する (PowerShell 版)
#
# 使い方:
#   pwsh check-mermaid.ps1 <root_dir>
#
# 動作:
#   1. <root_dir> 以下の *.md を探す
#   2. ```mermaid ... ``` ブロックを抽出
#   3. 各ブロックを一時ファイルに保存し、`mmdc -i <tmp> -o <out>` で SVG レンダリングを試みる
#      (実際の SVG は捨て、パスできるかだけを判定)
#
# exit code:
#   0 — 全 mermaid ブロックが parse OK (mermaid ブロックが 0 件でも OK)
#   1 — 1 件以上のパース失敗
#   127 — mmdc 未インストール (呼び出し側で skip 扱いに)

param(
  [string]$Root = "."
)

if (-not (Get-Command mmdc -ErrorAction SilentlyContinue)) {
  Write-Error "mmdc (mermaid-cli) not installed. install: npm install -g @mermaid-js/mermaid-cli"
  exit 127
}

$TmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("check-mermaid-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TmpRoot | Out-Null

$Total = 0
$FailCount = 0
$Pattern = [regex]::new('```mermaid\s*\n(.*?)\n```', [System.Text.RegularExpressions.RegexOptions]::Singleline)

try {
  Get-ChildItem -Path $Root -Recurse -File -Filter *.md | ForEach-Object {
    $text = Get-Content -Path $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $text) { return }
    $i = 0
    foreach ($m in $Pattern.Matches($text)) {
      $mmd = Join-Path $TmpRoot "$($_.Name).$i.mmd"
      Set-Content -Path $mmd -Value $m.Groups[1].Value -Encoding UTF8
      $script:Total++
      $outSvg = "$mmd.svg"
      & mmdc -i $mmd -o $outSvg *> $null
      if ($LASTEXITCODE -ne 0) {
        Write-Output "MERMAID PARSE FAIL: $mmd"
        $script:FailCount++
      }
      $i++
    }
  }
} finally {
  Remove-Item -Recurse -Force $TmpRoot -ErrorAction SilentlyContinue
}

Write-Output "check-mermaid: total=$Total fail=$FailCount"
if ($FailCount -ne 0) { exit 1 }
exit 0
