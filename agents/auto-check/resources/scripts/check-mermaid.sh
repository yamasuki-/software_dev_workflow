#!/usr/bin/env bash
# check-mermaid.sh — Markdown ファイル内の Mermaid ブロックを抽出して mmdc でパース検証する。
#
# 使い方:
#   bash check-mermaid.sh <root_dir>
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

set -u

ROOT="${1:-.}"

if ! command -v mmdc >/dev/null 2>&1; then
  echo "mmdc (mermaid-cli) not installed. install: npm install -g @mermaid-js/mermaid-cli" >&2
  exit 127
fi

FAIL_COUNT=0
TOTAL=0
TMPROOT=$(mktemp -d)
trap "rm -rf $TMPROOT" EXIT

# 抽出リストを一時ファイルに書き出してからメインシェルでループする
# (`... | while` のパイプラインはサブシェルで実行され、カウンタの加算が親シェルに
#  反映されず常に exit 0 になるバグがあったため、この構造にしている)
MMD_LIST="$TMPROOT/mmd-list.txt"
find "$ROOT" -type f -name "*.md" -print0 | while IFS= read -r -d '' f; do
  python3 - "$f" "$TMPROOT" <<'PY' || true
import sys, os, re, pathlib
src = pathlib.Path(sys.argv[1])
outdir = pathlib.Path(sys.argv[2])
text = src.read_text(encoding='utf-8', errors='replace')
pattern = re.compile(r"```mermaid\s*\n(.*?)\n```", re.DOTALL)
for i, m in enumerate(pattern.finditer(text)):
    block = m.group(1)
    out = outdir / f"{src.name}.{i}.mmd"
    out.write_text(block, encoding='utf-8')
    print(out, flush=True)
PY
done > "$MMD_LIST"

while IFS= read -r mmd; do
  [ -n "$mmd" ] || continue
  TOTAL=$((TOTAL + 1))
  out_svg="${mmd}.svg"
  if ! mmdc -i "$mmd" -o "$out_svg" >/dev/null 2>&1; then
    echo "MERMAID PARSE FAIL: $mmd"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done < "$MMD_LIST"

echo "check-mermaid: total=$TOTAL fail=$FAIL_COUNT"
if [ "$FAIL_COUNT" != "0" ]; then exit 1; fi
exit 0
