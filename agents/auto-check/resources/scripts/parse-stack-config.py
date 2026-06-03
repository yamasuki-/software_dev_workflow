#!/usr/bin/env python3
"""parse-stack-config.py

`stack-config.md` から「自動チェック (MUST / SHOULD / MAY)」セクションを抽出する。
ベース (stack 層) + project 層の 2 つを受け取り、フェーズごとにマージする。

Usage:
    python3 parse-stack-config.py --stack <path> [--project <path>] --phase <phase> [--common]

Output (JSON to stdout):
{
  "phase": "<phase>",
  "must":   [{"name": "...", "command": "...", "install_hint": "..."}, ...],
  "should": [...],
  "may":    [...]
}

stack-config.md の期待フォーマット:

## 自動チェック (MUST / SHOULD / MAY)

### 全フェーズ共通

#### MUST
- markdownlint-cli2 "**/*.md"   # install: npm i -g markdownlint-cli2
- bash scripts/check-mermaid.sh   # install: npm i -g @mermaid-js/mermaid-cli

#### SHOULD
- typos --no-check-filenames   # install: cargo install typos-cli

#### MAY
- lychee --no-progress "**/*.md"   # install: cargo install lychee

### <phase> 固有

#### MUST
- uv run ruff check .   # install: pip install uv
- uv run mypy src   # install: pip install uv

...

備考:
- `#` の右側にコメント (install hint など) を書ける
- リスト先頭の `-` だけがコマンド行として扱われる
- `### 全フェーズ共通` と `### <phase>` (例: `### implementation`) の両方を読む
- 各 tier 内の項目は **stack 層 ADD と project 層 ADD を加算**。project 層に同名コマンドがあれば置換。
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional


@dataclass
class Check:
    name: str  # 短い識別子 (コマンドの最初のトークン)
    command: str  # 実行コマンド (完全形)
    install_hint: str = ""

    def key(self) -> str:
        return self.name


HEADING_AUTO_CHECK = re.compile(r"^##\s*自動チェック")
HEADING_PHASE = re.compile(r"^###\s*(.+?)\s*$")
HEADING_TIER = re.compile(r"^####\s*(MUST|SHOULD|MAY)\s*$")
LIST_ITEM = re.compile(r"^-\s+(.+)$")
INSTALL_HINT = re.compile(r"#\s*install:\s*(.+)$")


def parse_section(text: str, target_phase: str) -> dict[str, list[Check]]:
    """Parse a stack-config.md text and return checks for the given phase + common."""
    result = {"MUST": [], "SHOULD": [], "MAY": []}
    in_auto_check = False
    current_phase: Optional[str] = None
    current_tier: Optional[str] = None

    for raw in text.splitlines():
        line = raw.rstrip("\n")
        if HEADING_AUTO_CHECK.match(line):
            in_auto_check = True
            current_phase = None
            current_tier = None
            continue
        if not in_auto_check:
            continue
        # Another ## section ends auto-check
        if line.startswith("## ") and not HEADING_AUTO_CHECK.match(line):
            in_auto_check = False
            continue

        m_phase = HEADING_PHASE.match(line)
        if m_phase:
            phase_label = m_phase.group(1).strip()
            current_tier = None
            # Match "全フェーズ共通" or the target phase (also accept "<phase> 固有")
            normalized = phase_label.replace("固有", "").strip()
            if normalized in ("全フェーズ共通", "common"):
                current_phase = "common"
            elif normalized == target_phase:
                current_phase = target_phase
            else:
                current_phase = None
            continue

        m_tier = HEADING_TIER.match(line)
        if m_tier:
            current_tier = m_tier.group(1)
            continue

        if current_phase and current_tier:
            m_item = LIST_ITEM.match(line)
            if m_item:
                body = m_item.group(1).strip()
                hint = ""
                m_hint = INSTALL_HINT.search(body)
                if m_hint:
                    hint = m_hint.group(1).strip()
                    body = body[: m_hint.start()].rstrip("# ").rstrip()
                # name = first token of the command (strip backticks if wrapped)
                command = body.strip("`").strip()
                first_token = command.split()[0] if command else ""
                result[current_tier].append(
                    Check(name=first_token or command, command=command, install_hint=hint)
                )
    return result


def merge_checks(base: dict[str, list[Check]], overlay: dict[str, list[Check]]) -> dict[str, list[Check]]:
    """overlay の同名 check は base を置換し、無いものは追加する。"""
    merged: dict[str, list[Check]] = {}
    for tier in ("MUST", "SHOULD", "MAY"):
        seen: dict[str, Check] = {c.key(): c for c in base.get(tier, [])}
        for c in overlay.get(tier, []):
            seen[c.key()] = c
        merged[tier] = list(seen.values())
    return merged


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stack", type=Path, required=True, help="stack 層の stack-config.md")
    ap.add_argument("--project", type=Path, default=None, help="project 層の stack-config.md (任意)")
    ap.add_argument("--phase", required=True, help="対象フェーズ名")
    args = ap.parse_args()

    if not args.stack.exists():
        print(f"stack-config not found: {args.stack}", file=sys.stderr)
        return 2

    stack_checks = parse_section(args.stack.read_text(encoding="utf-8"), args.phase)
    project_checks: dict[str, list[Check]] = {"MUST": [], "SHOULD": [], "MAY": []}
    if args.project and args.project.exists():
        project_checks = parse_section(args.project.read_text(encoding="utf-8"), args.phase)

    merged = merge_checks(stack_checks, project_checks)

    out = {
        "phase": args.phase,
        "must": [asdict(c) for c in merged["MUST"]],
        "should": [asdict(c) for c in merged["SHOULD"]],
        "may": [asdict(c) for c in merged["MAY"]],
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
