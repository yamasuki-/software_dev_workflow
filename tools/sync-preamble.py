#!/usr/bin/env python3
"""sync-preamble.py — 26 Agent に複製されている「Subagent definition 前文」の整合管理ツール。

背景:
    サブエージェントの system prompt は各 `agents/<name>/<name>.md` 単体で自己完結する
    必要があるため、共通前文は各ファイルに複製せざるを得ない (実行時に外部ファイルを
    参照できる保証がない)。複製の更新漏れを防ぐため、本スクリプトを正本 (single source
    of truth) とし、変更時はここを編集して --fix で全 Agent に一括反映する。

前文の構造 (frontmatter 直後の blockquote 4 行):
    1 行目: Subagent definition 宣言          (全 Agent 共通・本スクリプトが正本)
    2 行目: spawn 元 skill の説明             (Agent ごとに異なる・本スクリプトは触らない)
    3 行目: リソース解決順                    (全 Agent 共通・正本)
    4 行目: 共有ファイル書き込み禁止          (full / readonly の 2 変種・正本)

Usage:
    python tools/sync-preamble.py --check   # 全 Agent の前文が正本と一致するか検証 (CI 向け)
    python tools/sync-preamble.py --fix     # 正本の内容で 1/3/4 行目を一括更新 (2 行目は保持)

exit code: 0 = OK / 1 = 不一致あり (--check) / 2 = 実行エラー
"""
import argparse
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
AGENTS_DIR = REPO / "agents"

# ---- 正本 (ここを編集して --fix で反映する) ----------------------------------

LINE1 = "> **Subagent definition** — このファイルは Claude Code subagent として読み込まれる system prompt 本体。"

LINE3 = "> リソース (テンプレ・スクリプト) の解決順: (1) `<PROJECT_ROOT>/.dev-workflow/templates/<agent名>/` (初期化時にオーケストレータが集約コピー) → (2) `~/.claude/agents/<agent名>/resources/` (標準インストール先)。本文中の「本スキルディレクトリ配下の `resources/`」はこの解決順で読み替えること。"

LINE4_FULL = "> **共有ファイル書き込み禁止**: `project.json` / `open-questions.md` / `decisions.md` への直接書き込みはオーケストレータの専任 (並行 spawn 時の書き込み競合防止)。本文中にこれらへの「追記/記録」とある箇所は **戻り値の `open_questions` / `decisions` で返す** と読み替えること (オーケストレータが一元追記する)。機能別状態 (`features/<FID>/status.json`, `tasks/`, `bugs/`) と成果物 (`docs/`, `src/`, `tests/`) は本 Agent が直接書いてよい。"

LINE4_READONLY = "> **共有ファイル書き込み禁止**: `project.json` / `open-questions.md` / `decisions.md` への直接書き込みはオーケストレータの専任。記録すべき内容は **戻り値の `open_questions` / `decisions` で返す**。"

# readonly 変種を使う Agent (調査・提案・逆生成系。成果物レポート以外を書かない)
READONLY_AGENTS = {
    "code-survey",
    "conformance-test",
    "current-analysis",
    "reverse-design",
    "solution-proposal",
}

# ------------------------------------------------------------------------------


def split_file(text: str):
    """frontmatter / preamble(blockquote 連続行) / 残り に分割する。"""
    parts = text.split("---", 2)
    if len(parts) < 3:
        raise ValueError("frontmatter が見つからない")
    head = "---" + parts[1] + "---"
    body = parts[2]
    lines = body.split("\n")
    # 先頭の空行をスキップして blockquote 連続行を前文とみなす
    i = 0
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    start = i
    while i < len(lines) and lines[i].startswith(">"):
        i += 1
    preamble = lines[start:i]
    rest = "\n".join(lines[i:])
    lead = "\n".join(lines[:start])
    return head, lead, preamble, rest


def expected_line4(agent: str) -> str:
    return LINE4_READONLY if agent in READONLY_AGENTS else LINE4_FULL


def main() -> int:
    ap = argparse.ArgumentParser()
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--fix", action="store_true")
    args = ap.parse_args()

    ng = []
    fixed = []
    for d in sorted(AGENTS_DIR.iterdir()):
        f = d / f"{d.name}.md"
        if not f.is_file():
            continue
        agent = d.name
        text = f.read_text(encoding="utf-8")
        try:
            head, lead, pre, rest = split_file(text)
        except ValueError as e:
            ng.append(f"{agent}: {e}")
            continue
        if len(pre) != 4:
            ng.append(f"{agent}: 前文が 4 行でない ({len(pre)} 行)")
            continue
        problems = []
        if pre[0] != LINE1:
            problems.append("1 行目が正本と不一致")
        if not (pre[1].startswith("> ") and "spawn" in pre[1]):
            problems.append("2 行目 (spawn 元) の形式不正")
        if pre[2] != LINE3:
            problems.append("3 行目が正本と不一致")
        if pre[3] != expected_line4(agent):
            problems.append("4 行目が正本と不一致")

        if problems and args.fix:
            new_pre = [LINE1, pre[1], LINE3, expected_line4(agent)]
            new_text = head + lead + "\n" + "\n".join(new_pre) + rest
            f.write_text(new_text, encoding="utf-8")
            fixed.append(f"{agent}: {', '.join(problems)} → 修正")
        elif problems:
            ng.append(f"{agent}: {', '.join(problems)}")

    for line in fixed:
        print("FIXED", line)
    for line in ng:
        print("NG   ", line)
    if not ng and not fixed:
        print("OK: 全 Agent の前文が正本と一致")
    return 1 if ng else 0


if __name__ == "__main__":
    sys.exit(main())
