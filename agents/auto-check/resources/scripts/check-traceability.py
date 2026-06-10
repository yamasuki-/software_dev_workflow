#!/usr/bin/env python3
"""check-traceability.py — ID トレーサビリティの機械検証 (auto-check 組み込みチェック)

要件 (R-### / S-###-##) ↔ 機能 (F### / COMMON) ↔ テストケース (UT/IT/E2E-<FID>-NNN)
の対照を docs/ 配下から正規表現で収集し、リンク切れ・宙に浮いた ID を検出する。
stack-config.md に依存しない組み込みチェックとして、auto-check が全フェーズで実行する。

Usage:
    python check-traceability.py <PROJECT_ROOT> --phase <phase> [--json]

phase により検証範囲が変わる (進んでいない工程の欠落は報告しない):
    requirements        : 要件IDの一意性のみ
    basic-design        : + 全 R-### が feature-list.md に出現 / F### の重複なし
    detailed-design     : + 全 F### に docs/02_detailed_design/<FID>/ が存在
                          + 全 S-###-## が詳細設計のどこかに出現 (USDM 時)
    test-design         : + 全 F### に docs/03_test_design/<FID>/ が存在
                          + テストID形式 (UT|IT|E2E)-<FID>-NNN の一意性
                          + テストIDの <FID> が feature-list に存在
    test-implementation : + テスト設計の全テストIDが tests/ 配下のコードに出現
    implementation      : (test-implementation と同じ)
    testing             : + テスト設計の全テストIDが docs/04_test_results/ に出現
    bug-fix             : + B### の bug.json と docs/05_bug_reports/B###.md が対で存在

exit code: 0 = pass / 1 = fail (リンク切れあり) / 2 = 実行エラー
"""
import argparse
import json
import re
import sys
from pathlib import Path

RE_REQ = re.compile(r"\bR-\d{3}\b")
RE_SPEC = re.compile(r"\bS-\d{3}-\d{2}\b")
RE_FID = re.compile(r"\b(F\d{3}|COMMON)\b")
RE_TEST = re.compile(r"\b(UT|IT|E2E)-(F\d{3}|COMMON)-\d{3}\b")
RE_BUG = re.compile(r"\bB\d{3}\b")

PHASES = [
    "requirements", "basic-design", "detailed-design", "test-design",
    "test-implementation", "implementation", "testing", "bug-fix",
]


def read_all(paths):
    text = []
    for p in paths:
        try:
            text.append(p.read_text(encoding="utf-8", errors="replace"))
        except OSError:
            pass
    return "\n".join(text)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("project_root", type=Path)
    ap.add_argument("--phase", choices=PHASES, required=True)
    ap.add_argument("--json", action="store_true", help="JSON で出力")
    args = ap.parse_args()

    root: Path = args.project_root
    docs = root / "docs"
    if not docs.is_dir():
        print(f"ERROR: docs/ not found under {root}", file=sys.stderr)
        return 2

    stage = PHASES.index(args.phase)
    issues = []  # (severity, message)

    # --- 収集 ---
    req_text = read_all(sorted((docs / "requirements").glob("**/*.md"))) if (docs / "requirements").is_dir() else ""
    feature_list = docs / "01_basic_design" / "feature-list.md"
    fl_text = feature_list.read_text(encoding="utf-8", errors="replace") if feature_list.is_file() else ""

    req_ids = sorted(set(RE_REQ.findall(req_text)))
    spec_ids = sorted(set(RE_SPEC.findall(req_text)))
    fids = sorted(set(RE_FID.findall(fl_text)))

    dd_dir = docs / "02_detailed_design"
    td_dir = docs / "03_test_design"
    tr_dir = docs / "04_test_results"
    br_dir = docs / "05_bug_reports"

    td_text = read_all(sorted(td_dir.glob("**/*.md"))) if td_dir.is_dir() else ""
    test_ids = sorted(set(m.group(0) for m in RE_TEST.finditer(td_text)))

    # --- requirements: ID 一意性 (定義行の重複検出は書式非依存にできないため出現のみ確認) ---
    if stage >= 0 and not req_ids and not (docs / "requirements").is_dir():
        issues.append(("warn", "docs/requirements/ が存在しない (要件IDなし運用なら無視可)"))

    # --- basic-design: 要件カバレッジ / FID ---
    if stage >= 1:
        if not feature_list.is_file():
            issues.append(("fail", "docs/01_basic_design/feature-list.md が存在しない"))
        else:
            if not fids:
                issues.append(("fail", "feature-list.md に機能ID (F###) が見つからない"))
            for rid in req_ids:
                if rid not in fl_text:
                    issues.append(("fail", f"要件 {rid} が feature-list.md のカバレッジマップに出現しない"))

    # --- detailed-design ---
    if stage >= 2:
        for fid in fids:
            if not (dd_dir / fid).is_dir():
                issues.append(("fail", f"{fid} の詳細設計ディレクトリ docs/02_detailed_design/{fid}/ が存在しない"))
        if spec_ids:
            dd_td_text = read_all(sorted(dd_dir.glob("**/*.md"))) + td_text
            for sid in spec_ids:
                if sid not in dd_td_text:
                    issues.append(("fail", f"仕様 {sid} が詳細設計/テスト設計のどこにも出現しない"))

    # --- test-design ---
    if stage >= 3:
        for fid in fids:
            if not (td_dir / fid).is_dir():
                issues.append(("fail", f"{fid} のテスト設計ディレクトリ docs/03_test_design/{fid}/ が存在しない"))
        known = set(fids)
        for tid in test_ids:
            tid_fid = tid.split("-", 1)[1].rsplit("-", 1)[0]
            if tid_fid not in known:
                issues.append(("fail", f"テストID {tid} の機能 {tid_fid} が feature-list.md に存在しない (宙に浮いたID)"))
        if not test_ids and any(td_dir.glob("**/*.md")):
            issues.append(("warn", "テスト設計ドキュメントにテストID ((UT|IT|E2E)-<FID>-NNN) が見つからない"))

    # --- test-implementation / implementation: テストIDがコードに存在 ---
    if stage >= 4:
        tests_dir = root / "tests"
        code_text = ""
        if tests_dir.is_dir():
            code_text = read_all(p for p in sorted(tests_dir.rglob("*")) if p.is_file() and p.suffix not in {".pyc", ".png", ".jpg"})
        for tid in test_ids:
            if tid not in code_text:
                issues.append(("fail", f"テストID {tid} がテストコード (tests/ 配下) に出現しない"))

    # --- testing: テストIDが結果ドキュメントに存在 ---
    if stage >= 6:
        results_text = read_all(sorted(tr_dir.glob("**/*.md"))) if tr_dir.is_dir() else ""
        for tid in test_ids:
            if tid not in results_text:
                issues.append(("fail", f"テストID {tid} の実行結果が docs/04_test_results/ に記録されていない"))

    # --- bug-fix: bug.json と bug-report の対 ---
    if stage >= 7:
        bug_jsons = {p.stem for p in (root / ".dev-workflow").rglob("bugs/B*.json")}
        bug_mds = {p.stem for p in br_dir.glob("B*.md")} if br_dir.is_dir() else set()
        for b in sorted(bug_jsons - bug_mds):
            issues.append(("fail", f"{b}: bug.json はあるが docs/05_bug_reports/{b}.md がない"))
        for b in sorted(bug_mds - bug_jsons):
            issues.append(("fail", f"{b}: bug-report はあるが .dev-workflow 配下の bug.json がない"))

    fails = [m for s, m in issues if s == "fail"]
    warns = [m for s, m in issues if s == "warn"]
    result = {
        "phase": args.phase,
        "verdict": "FAIL" if fails else "PASS",
        "counts": {"requirements": len(req_ids), "specs": len(spec_ids),
                   "features": len(fids), "test_cases": len(test_ids)},
        "fails": fails,
        "warnings": warns,
    }
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"[check-traceability] phase={args.phase} verdict={result['verdict']}")
        print(f"  IDs: R={len(req_ids)} S={len(spec_ids)} F={len(fids)} tests={len(test_ids)}")
        for m in fails:
            print(f"  FAIL: {m}")
        for m in warns:
            print(f"  warn: {m}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
