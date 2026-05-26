#!/usr/bin/env bash
# run-tests.sh — test-run スキル用のテスト実行ヘルパ (bash 版)
#
# 使い方:
#   bash run-tests.sh \
#     --project-root <path> \
#     --phase <test-implementation|implementation> \
#     --mode <red|green> \
#     --target <FID> \
#     --layers "unit,integration,e2e"
#
# 動作:
#   1. stack-config.md の「テスト実行コマンド」セクションから各層のコマンドを抽出
#   2. <FID> プレースホルダを置換して順次実行
#   3. 結果を docs/04_test_results/<FID>/<phase>-<mode>-run.log と
#      docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md に出力
#   4. 集計を stderr に AUTO_RUN_SUMMARY として吐く
#
# exit code:
#   0   — verdict=PASS (期待通り)
#   10  — verdict=FAIL (期待と異なる)
#   2   — 引数 / 設定エラー

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_ROOT=""
PHASE=""
MODE=""
TARGET=""
LAYERS="unit,integration,e2e"

while [ $# -gt 0 ]; do
  case "$1" in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    --phase)        PHASE="$2"; shift 2 ;;
    --mode)         MODE="$2"; shift 2 ;;
    --target)       TARGET="$2"; shift 2 ;;
    --layers)       LAYERS="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,25p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$PROJECT_ROOT" ] || [ -z "$PHASE" ] || [ -z "$MODE" ] || [ -z "$TARGET" ]; then
  echo "usage: --project-root / --phase / --mode / --target are required" >&2
  exit 2
fi

STACK_CFG="$PROJECT_ROOT/.dev-workflow/rules/stack/stack-config.md"
PROJECT_CFG="$PROJECT_ROOT/.dev-workflow/rules/project/stack-config.md"

if [ ! -f "$STACK_CFG" ]; then
  echo "stack-config.md not found at $STACK_CFG" >&2
  echo "test-run requires .dev-workflow/rules/stack/stack-config.md (from a stack-presets preset)" >&2
  exit 2
fi

OUT_DIR="$PROJECT_ROOT/docs/04_test_results/$TARGET"
mkdir -p "$OUT_DIR"
LOG="$OUT_DIR/$PHASE-$MODE-run.log"
REPORT="$OUT_DIR/$PHASE-$MODE-confirmation.md"

# Extract command for a given layer using parse-stack-config-tests.py
# (parse helper is small and lives next to this script)
extract_command() {
  local layer="$1"
  python3 "$SCRIPT_DIR/parse-results.py" --mode extract-command \
    --stack "$STACK_CFG" \
    ${PROJECT_CFG:+--project "$PROJECT_CFG"} \
    --layer "$layer" \
    --fid "$TARGET" 2>/dev/null
}

START_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

declare -A LAYER_TOTAL
declare -A LAYER_PASS
declare -A LAYER_FAIL
declare -A LAYER_SKIP
declare -A LAYER_XFAIL
declare -A LAYER_EXIT
declare -A LAYER_DUR
declare -A LAYER_CMD
declare -A LAYER_OUT

IFS=',' read -ra LAYER_ARR <<< "$LAYERS"
for layer in "${LAYER_ARR[@]}"; do
  cmd=$(extract_command "$layer")
  if [ -z "$cmd" ]; then
    LAYER_TOTAL[$layer]=0; LAYER_PASS[$layer]=0; LAYER_FAIL[$layer]=0
    LAYER_SKIP[$layer]=0; LAYER_XFAIL[$layer]=0
    LAYER_EXIT[$layer]="-"; LAYER_DUR[$layer]=0
    LAYER_CMD[$layer]="(no command defined for $layer in stack-config.md)"
    LAYER_OUT[$layer]=""
    continue
  fi
  LAYER_CMD[$layer]="$cmd"
  started=$(date +%s)
  tmpout=$(mktemp)
  bash -c "cd '$PROJECT_ROOT' && $cmd" > "$tmpout" 2>&1
  code=$?
  ended=$(date +%s)
  LAYER_EXIT[$layer]=$code
  LAYER_DUR[$layer]=$((ended - started))
  # Parse results from output (works for pytest / vitest / jest / go test best-effort)
  parsed=$(python3 "$SCRIPT_DIR/parse-results.py" --mode parse-output --layer "$layer" < "$tmpout")
  # parsed format: total pass fail skip xfail
  read total pass fail skip xfail <<< "$parsed"
  LAYER_TOTAL[$layer]=${total:-0}
  LAYER_PASS[$layer]=${pass:-0}
  LAYER_FAIL[$layer]=${fail:-0}
  LAYER_SKIP[$layer]=${skip:-0}
  LAYER_XFAIL[$layer]=${xfail:-0}
  LAYER_OUT[$layer]=$(head -100 "$tmpout")
  cat "$tmpout" >> "$LOG"
  echo "" >> "$LOG"
  rm -f "$tmpout"
done

# Aggregate
TOTAL=0; PASS=0; FAIL=0; SKIP=0; XFAIL=0
for layer in "${LAYER_ARR[@]}"; do
  TOTAL=$((TOTAL + ${LAYER_TOTAL[$layer]:-0}))
  PASS=$((PASS + ${LAYER_PASS[$layer]:-0}))
  FAIL=$((FAIL + ${LAYER_FAIL[$layer]:-0}))
  SKIP=$((SKIP + ${LAYER_SKIP[$layer]:-0}))
  XFAIL=$((XFAIL + ${LAYER_XFAIL[$layer]:-0}))
done

# Verdict
VERDICT="PASS"
case "$MODE" in
  red)
    # 全 fail: failed > 0 かつ passed = 0 (skip / xfail を除外)
    if [ "$FAIL" -gt 0 ] && [ "$PASS" -eq 0 ]; then VERDICT="PASS"; else VERDICT="FAIL"; fi
    EXPECTED_TEXT="全テスト Fail (Red)"
    ;;
  green)
    if [ "$FAIL" -eq 0 ] && [ "$PASS" -gt 0 ]; then VERDICT="PASS"; else VERDICT="FAIL"; fi
    EXPECTED_TEXT="全テスト Pass (Green)"
    ;;
  *)
    echo "invalid mode: $MODE (must be red|green)" >&2
    exit 2
    ;;
esac

OBSERVED_TEXT="executed=$TOTAL pass=$PASS fail=$FAIL skip=$SKIP xfail=$XFAIL"

# Write report
{
  echo "# $PHASE — $MODE 確認 (test-run)"
  echo
  echo "実行日時: $START_AT"
  echo "対象機能: $TARGET"
  echo "モード: $MODE"
  echo "プロジェクトルート: $PROJECT_ROOT"
  echo "実行環境: $(uname -a)"
  echo
  echo "## サマリ"
  echo
  echo "| 層           | 実行 | pass | fail | skip | xfail | 判定 |"
  echo "|--------------|------|------|------|------|-------|------|"
  for layer in "${LAYER_ARR[@]}"; do
    printf "| %s | %s | %s | %s | %s | %s | - |\n" \
      "$layer" "${LAYER_TOTAL[$layer]}" "${LAYER_PASS[$layer]}" "${LAYER_FAIL[$layer]}" \
      "${LAYER_SKIP[$layer]}" "${LAYER_XFAIL[$layer]}"
  done
  printf "| **合計** | %s | %s | %s | %s | %s | **%s** |\n" "$TOTAL" "$PASS" "$FAIL" "$SKIP" "$XFAIL" "$VERDICT"
  echo
  echo "期待: $EXPECTED_TEXT"
  echo "実際: $OBSERVED_TEXT"
  echo
  echo "**判定: $VERDICT**"
  echo
  echo "## 各層の実行コマンドと出力"
  echo
  for layer in "${LAYER_ARR[@]}"; do
    echo "### $layer"
    echo "- コマンド: \`${LAYER_CMD[$layer]}\`"
    echo "- exit code: ${LAYER_EXIT[$layer]}"
    echo "- 実行時間: ${LAYER_DUR[$layer]}s"
    echo "- 出力 (先頭 100 行):"
    echo
    echo '```'
    echo "${LAYER_OUT[$layer]}"
    echo '```'
    echo
  done
} > "$REPORT"

# Emit summary to stderr
{
  echo "AUTO_RUN_SUMMARY phase=$PHASE mode=$MODE target=$TARGET"
  echo "  total=$TOTAL pass=$PASS fail=$FAIL skip=$SKIP xfail=$XFAIL"
  echo "  verdict=$VERDICT"
  echo "  report=$REPORT"
  echo "  log=$LOG"
} 1>&2

if [ "$VERDICT" = "FAIL" ]; then exit 10; fi
exit 0
