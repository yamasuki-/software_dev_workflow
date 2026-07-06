#!/usr/bin/env bash
# run-checks.sh — auto-check の本体ランナー (bash 版)
#
# 使い方:
#   bash run-checks.sh \
#     --project-root <path> \
#     --phase <basic-design|detailed-design|...> \
#     --mode <per_feature|cross> \
#     --target <FID|ALL> \
#     [--out <report.md>]
#
# 動作:
#   1. parse-stack-config.py で MUST/SHOULD/MAY のコマンド一覧を JSON で取得
#   2. check-tools.sh で各ツールの存在確認
#   3. インストール済みコマンドを順次実行し、結果を集計
#   4. report-template.md に従ってレポート Markdown を出力
#   5. 状態 JSON (project.json / features/<FID>/status.json) は呼び出し側 (Claude/Agent) が更新する
#      (シェルスクリプトは jq に依存しないため、JSON 更新は Agent 側で行う設計)
#
# exit code:
#   0   — MUST 全 pass (skipped を含む)
#   10  — MUST に fail あり
#   2   — 引数エラー

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_ROOT=""
PHASE=""
MODE="per_feature"
TARGET="ALL"
OUT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    --phase)        PHASE="$2"; shift 2 ;;
    --mode)         MODE="$2"; shift 2 ;;
    --target)       TARGET="$2"; shift 2 ;;
    --out)          OUT="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$PROJECT_ROOT" ] || [ -z "$PHASE" ]; then
  echo "usage: --project-root and --phase are required" >&2
  exit 2
fi

STACK_CFG="$PROJECT_ROOT/.dev-workflow/rules/stack/stack-config.md"
PROJECT_CFG="$PROJECT_ROOT/.dev-workflow/rules/project/stack-config.md"

if [ ! -f "$STACK_CFG" ]; then
  echo "stack-config.md not found at $STACK_CFG" >&2
  echo "auto-check requires .dev-workflow/rules/stack/stack-config.md (from a stack-presets preset)" >&2
  exit 2
fi

PARSE_ARGS=(--stack "$STACK_CFG" --phase "$PHASE")
if [ -f "$PROJECT_CFG" ]; then
  PARSE_ARGS=(--project "$PROJECT_CFG" "${PARSE_ARGS[@]}")
fi

PARSED_JSON=$(python3 "$SCRIPT_DIR/parse-stack-config.py" "${PARSE_ARGS[@]}")
if [ $? -ne 0 ]; then
  echo "parse-stack-config.py failed" >&2
  exit 2
fi

now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
START_AT=$(now)

# Default report path
if [ -z "$OUT" ]; then
  if [ "$MODE" = "cross" ]; then
    OUT_DIR="$PROJECT_ROOT/docs/06_reviews/_cross"
  else
    OUT_DIR="$PROJECT_ROOT/docs/06_reviews/$TARGET"
  fi
  mkdir -p "$OUT_DIR"
  OUT="$OUT_DIR/$PHASE-auto-check.md"
fi

# JSON helpers (use python to avoid jq dependency)
tier_items() {
  echo "$PARSED_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for item in data.get('$1'.lower(), []):
    print('{}\t{}\t{}'.format(item['name'], item['command'], item.get('install_hint', '')))
"
}

# Execute commands of a tier and emit a TSV log to stdout:
#   <tier>\t<name>\t<exit_code>\t<duration_sec>\t<status>\t<output_b64>
# where status is one of: PASS|FAIL|SKIPPED_MISSING
run_tier() {
  local tier="$1"
  while IFS=$'\t' read -r name cmd hint; do
    [ -z "$name" ] && continue
    # Check tool presence (first token)
    local first
    first=$(echo "$cmd" | awk '{print $1}')
    if ! command -v "$first" >/dev/null 2>&1; then
      printf "%s\t%s\t-\t-\t%s\t%s\t%s\n" "$tier" "$name" "SKIPPED_MISSING" "" "$hint"
      continue
    fi
    local started
    started=$(date +%s)
    local tmpout
    tmpout=$(mktemp)
    bash -c "$cmd" > "$tmpout" 2>&1
    local code=$?
    local ended
    ended=$(date +%s)
    local dur=$((ended - started))
    local status
    if [ $code -eq 0 ]; then status="PASS"; else status="FAIL"; fi
    # Take first 50 lines
    local snippet
    snippet=$(head -50 "$tmpout" | base64 | tr -d '\n')
    rm -f "$tmpout"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$tier" "$name" "$code" "$dur" "$status" "$snippet" "$cmd"
  done < <(tier_items "$tier")
}

# Run all tiers
RESULTS_TSV=$(mktemp)
{
  run_tier MUST
  run_tier SHOULD
  run_tier MAY
} > "$RESULTS_TSV"

# Summarize
count_status() {
  local tier="$1"; local status="$2"
  awk -F'\t' -v t="$tier" -v s="$status" '$1==t && $5==s' "$RESULTS_TSV" | wc -l | tr -d ' '
}
total_of_tier() { awk -F'\t' -v t="$1" '$1==t' "$RESULTS_TSV" | wc -l | tr -d ' '; }

MUST_TOTAL=$(total_of_tier MUST)
MUST_PASS=$(count_status MUST PASS)
MUST_FAIL=$(count_status MUST FAIL)
MUST_SKIP=$(count_status MUST SKIPPED_MISSING)
SHOULD_TOTAL=$(total_of_tier SHOULD)
SHOULD_PASS=$(count_status SHOULD PASS)
SHOULD_FAIL=$(count_status SHOULD FAIL)
SHOULD_SKIP=$(count_status SHOULD SKIPPED_MISSING)
MAY_TOTAL=$(total_of_tier MAY)
MAY_PASS=$(count_status MAY PASS)
MAY_FAIL=$(count_status MAY FAIL)
MAY_SKIP=$(count_status MAY SKIPPED_MISSING)

VERDICT="PASS"
if [ "$MUST_FAIL" != "0" ]; then VERDICT="FAIL (MUST 失敗あり)"; fi

# Write report
{
  echo "# $PHASE — auto-check 結果"
  echo
  echo "実行日時: $START_AT"
  echo "対象モード: $MODE"
  echo "対象機能: $TARGET"
  echo "プロジェクトルート: $PROJECT_ROOT"
  echo "実行環境: $(uname -a)"
  echo
  echo "## サマリ"
  echo
  echo "| 階層   | 実行 | pass | fail | skipped (missing) |"
  echo "|--------|------|------|------|-------------------|"
  printf "| MUST   | %s | %s | %s | %s |\n" "$MUST_TOTAL" "$MUST_PASS" "$MUST_FAIL" "$MUST_SKIP"
  printf "| SHOULD | %s | %s | %s | %s |\n" "$SHOULD_TOTAL" "$SHOULD_PASS" "$SHOULD_FAIL" "$SHOULD_SKIP"
  printf "| MAY    | %s | %s | %s | %s |\n" "$MAY_TOTAL" "$MAY_PASS" "$MAY_FAIL" "$MAY_SKIP"
  echo
  echo "**判定: $VERDICT**"
  echo
  for tier in MUST SHOULD MAY; do
    echo "## $tier 詳細"
    echo
    awk -F'\t' -v t="$tier" '$1==t' "$RESULTS_TSV" | while IFS=$'\t' read -r _ name code dur status snippet cmd; do
      if [ "$status" = "SKIPPED_MISSING" ]; then
        echo "### $name"
        echo "- status: SKIPPED (tool not installed)"
        echo "- install hint: \`$cmd\`"
        echo
        continue
      fi
      echo "### $name"
      echo "- コマンド: \`$cmd\`"
      echo "- exit code: $code"
      echo "- 実行時間: ${dur}s"
      echo "- 出力 (先頭 50 行):"
      echo
      echo '```'
      echo "$snippet" | base64 -d 2>/dev/null || echo "(no output)"
      echo '```'
      echo
    done
  done
} > "$OUT"

rm -f "$RESULTS_TSV"

# Emit machine-readable summary to stderr for the calling agent
{
  echo "AUTO_CHECK_SUMMARY phase=$PHASE mode=$MODE target=$TARGET"
  echo "  MUST   total=$MUST_TOTAL pass=$MUST_PASS fail=$MUST_FAIL skipped=$MUST_SKIP"
  echo "  SHOULD total=$SHOULD_TOTAL pass=$SHOULD_PASS fail=$SHOULD_FAIL skipped=$SHOULD_SKIP"
  echo "  MAY    total=$MAY_TOTAL pass=$MAY_PASS fail=$MAY_FAIL skipped=$MAY_SKIP"
  echo "  verdict=$VERDICT"
  echo "  report=$OUT"
} 1>&2

if [ "$MUST_FAIL" != "0" ]; then
  exit 10
fi
exit 0
