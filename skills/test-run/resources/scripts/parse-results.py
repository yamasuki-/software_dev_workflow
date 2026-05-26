#!/usr/bin/env python3
"""parse-results.py — test-run スキル用のサブツール

機能 (--mode で切り替え):

1. extract-command : stack-config.md (および project-config.md) の
   「テスト実行コマンド」セクションから指定 layer のコマンドを取り出し、<FID> を置換して stdout に出す
2. parse-output    : テストランナーの出力 (stdin) をパースして
   "total pass fail skip xfail" を空白区切りで stdout に出す。
   pytest / vitest / jest / go test を best-effort で識別

Usage:
    python3 parse-results.py --mode extract-command --stack <path> [--project <path>] --layer <unit|integration|e2e> --fid <FID>
    cat output.txt | python3 parse-results.py --mode parse-output --layer <unit|integration|e2e>
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Optional


# --- extract-command ---

HEADING_SECTION = re.compile(r"^##\s*テスト実行コマンド")
HEADING_LAYER = re.compile(r"^###\s*(.+?)\s*$")
COMMAND_LINE = re.compile(r"^-\s*command:\s*(.+)$")


def extract_command(stack_path: Path, project_path: Optional[Path], layer: str, fid: str) -> Optional[str]:
    """Search stack first, then project layer overrides. Return command for the layer."""
    def parse(path: Path) -> dict[str, str]:
        out: dict[str, str] = {}
        in_section = False
        cur_layer: Optional[str] = None
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            if HEADING_SECTION.match(line):
                in_section = True
                continue
            if not in_section:
                continue
            if line.startswith("## ") and not HEADING_SECTION.match(line):
                in_section = False
                continue
            m = HEADING_LAYER.match(line)
            if m:
                label = m.group(1).strip().split()[0].lower()
                # accept patterns like "### 単体 (unit)" or "### unit"
                if "unit" in line or "単体" in line:
                    cur_layer = "unit"
                elif "integration" in line or "結合" in line:
                    cur_layer = "integration"
                elif "e2e" in line or "E2E" in line:
                    cur_layer = "e2e"
                else:
                    cur_layer = label
                continue
            mc = COMMAND_LINE.match(line.strip())
            if mc and cur_layer:
                out[cur_layer] = mc.group(1).strip()
        return out

    stack_cmds = parse(stack_path)
    project_cmds: dict[str, str] = {}
    if project_path and project_path.exists():
        project_cmds = parse(project_path)

    cmd = project_cmds.get(layer) or stack_cmds.get(layer)
    if not cmd:
        return None
    return cmd.replace("<FID>", fid)


# --- parse-output ---

# pytest: "===== 3 passed, 1 failed, 2 skipped, 1 xfailed in 1.23s ====="
PYTEST_SUMMARY = re.compile(
    r"=+\s*(?:(\d+)\s+passed)?(?:[,\s]+(\d+)\s+failed)?(?:[,\s]+(\d+)\s+skipped)?(?:[,\s]+(\d+)\s+xfailed)?.*?in\s+[\d.]+s",
    re.IGNORECASE,
)

# vitest / jest:
#   "Test Files  3 passed (3)"
#   "Tests       12 passed (12)"
#   "Tests:       5 passed, 1 failed, 1 skipped, 7 total"
VITEST_PASSED = re.compile(r"Tests?\s+\d+\s+passed", re.IGNORECASE)
JEST_LINE = re.compile(
    r"Tests:\s+(?:(\d+)\s+passed)?,?\s*(?:(\d+)\s+failed)?,?\s*(?:(\d+)\s+skipped)?,?\s*(\d+)\s+total",
    re.IGNORECASE,
)

# go test:
#   "PASS"
#   "FAIL"
#   "ok      example/foo  0.123s"
#   "--- PASS: TestFoo (0.01s)"
#   "--- FAIL: TestBar (0.01s)"
GO_RESULT = re.compile(r"^---\s+(PASS|FAIL|SKIP):", re.MULTILINE)


def parse_output(text: str, layer: str) -> tuple[int, int, int, int, int]:
    """Return (total, passed, failed, skipped, xfailed). Best effort across runners."""

    # pytest
    for m in PYTEST_SUMMARY.finditer(text):
        groups = [int(g) if g else 0 for g in m.groups()]
        passed, failed, skipped, xfailed = groups
        total = passed + failed + skipped + xfailed
        if total > 0:
            return total, passed, failed, skipped, xfailed

    # jest
    m = JEST_LINE.search(text)
    if m:
        passed = int(m.group(1) or 0)
        failed = int(m.group(2) or 0)
        skipped = int(m.group(3) or 0)
        total = int(m.group(4) or (passed + failed + skipped))
        return total, passed, failed, skipped, 0

    # vitest: less structured, fall back to scanning
    if VITEST_PASSED.search(text):
        # crude scan
        passed = 0
        failed = 0
        skipped = 0
        for m2 in re.finditer(r"Tests?\s+(\d+)\s+passed", text, re.IGNORECASE):
            passed = max(passed, int(m2.group(1)))
        for m2 in re.finditer(r"Tests?\s+(\d+)\s+failed", text, re.IGNORECASE):
            failed = max(failed, int(m2.group(1)))
        for m2 in re.finditer(r"Tests?\s+(\d+)\s+skipped", text, re.IGNORECASE):
            skipped = max(skipped, int(m2.group(1)))
        total = passed + failed + skipped
        if total > 0:
            return total, passed, failed, skipped, 0

    # go test
    if GO_RESULT.search(text):
        passed = len(re.findall(r"^---\s+PASS:", text, re.MULTILINE))
        failed = len(re.findall(r"^---\s+FAIL:", text, re.MULTILINE))
        skipped = len(re.findall(r"^---\s+SKIP:", text, re.MULTILINE))
        total = passed + failed + skipped
        if total > 0:
            return total, passed, failed, skipped, 0

    # Unknown / no tests detected
    return 0, 0, 0, 0, 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["extract-command", "parse-output"], required=True)
    ap.add_argument("--stack", type=Path)
    ap.add_argument("--project", type=Path)
    ap.add_argument("--layer", required=True)
    ap.add_argument("--fid", default="")
    args = ap.parse_args()

    if args.mode == "extract-command":
        if not args.stack or not args.stack.exists():
            print("", end="")
            return 0
        cmd = extract_command(args.stack, args.project, args.layer, args.fid)
        if cmd:
            print(cmd)
        return 0

    if args.mode == "parse-output":
        text = sys.stdin.read()
        total, passed, failed, skipped, xfailed = parse_output(text, args.layer)
        print(f"{total} {passed} {failed} {skipped} {xfailed}")
        return 0

    return 2


if __name__ == "__main__":
    sys.exit(main())
