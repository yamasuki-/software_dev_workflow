#!/usr/bin/env bash
# check-tools.sh — 指定されたツール群がインストールされているか確認する。
#
# 使い方:
#   bash check-tools.sh <tool1> <tool2> ...
#
# 出力 (1 行 1 ツール、TAB 区切り):
#   <tool>\tOK\t<version>
#   <tool>\tMISSING\t-
#
# exit code: 常に 0 (呼び出し側で MISSING を集計する)

set -u

probe() {
  local tool="$1"
  local version_arg="${2:---version}"

  if ! command -v "$tool" >/dev/null 2>&1; then
    printf "%s\tMISSING\t-\n" "$tool"
    return
  fi

  local ver
  ver=$("$tool" $version_arg 2>&1 | head -1 | tr -d '\r\n' || true)
  if [ -z "$ver" ]; then
    ver="(version unknown)"
  fi
  printf "%s\tOK\t%s\n" "$tool" "$ver"
}

if [ "$#" -eq 0 ]; then
  cat <<'EOF' >&2
usage: bash check-tools.sh <tool> [<tool> ...]

Examples:
  bash check-tools.sh markdownlint-cli2 mmdc textlint typos lychee
  bash check-tools.sh ruff mypy pytest
EOF
  exit 2
fi

for t in "$@"; do
  probe "$t"
done
