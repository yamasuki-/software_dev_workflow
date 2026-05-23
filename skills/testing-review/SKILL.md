---
name: testing-review
description: testing フェーズ完了時に、すべてのテストが実施完了しているか、未実施や「実施不可」で終わっていないかを検証する専用レビュースキル。テスト設計の全テストIDが結果ドキュメントに登場するか、Fail に対応する不具合票が起票されているか、Skip/未実施の理由が記録されているかを確認し pass/fail を返す。dev-workflow オーケストレータから機能ごとに自動で spawn される。
---

# testing-review — テスト結果レビュー (完了性確認)

## サブエージェント実行前提

- `dev-workflow` から **対象機能の testing 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `result` / `issues[]` / `next_action` / `updated_files` / `proceed_to`(次フェーズの示唆: `bug_fix` か `done`)。
- レビュー票は `docs/06_reviews/<FID>/testing-review.md`。

## 役割

ユーザの指示どおり、テスト結果レビューでは以下を **必ず** 確認する:

1. **すべてのテストが必ず終えているか** (テスト設計の全テストIDが結果に出現すること)
2. **実施不可で終えてないか** (`未実施`, `実施不可`, `skipped (理由不明)` のような状態が残っていないこと)
3. Fail がある場合、対応する不具合票が起票され `open_bugs` に登録されているか

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                | アウトプット                                                |
| --------------------------------------------------------- | ----------------------------------------------------------- |
| `docs/03_test_design/<FID>/{unit,integration,e2e}-test.md` | `docs/04_test_results/<FID>/{unit,integration,e2e}-test-result.md` |
| `tests/<layer>/<FID>/...` (実テストコード)                | `.dev-workflow/features/<FID>/bugs/B<NNN>.json` (Fail がある場合) |
|                                                           | `docs/05_bug_reports/B<NNN>.md` (Fail がある場合)            |
|                                                           | `.dev-workflow/features/<FID>/status.json`                  |

## チェックリスト

### A. 完全実施の確認 (最重要)
- [ ] **テスト設計の全テストID が結果ドキュメントの行に1件以上ある** (取りこぼし無し)
- [ ] 各テストIDに対し結果が `pass` / `fail` / `skip` のいずれかで明示されている
- [ ] **`未実施` / `実施不可` / `pending` / 空欄 が残っていない**
- [ ] `skip` がある場合、**その理由が明示** されており、ユーザ確認済み (`decisions.md` に記録)
- [ ] サマリ表 (計画/実行/Pass/Fail/Skip 件数) が記入されている
- [ ] 計画件数 = テスト設計のテストID 件数 と一致

### B. 実施不可の禁止
- [ ] 「実施不可」「未実装で実行不能」「環境構築できないため未実行」のような **テストとして完了していない状態** が結果に1件も無い
- [ ] そのような状態がある場合は、**unrecoverable な実施不可ではない**ことを確認するため、`docs/06_reviews/<FID>/testing-review.md` の不整合欄に列挙し、testing フェーズに戻すよう推奨

### C. Fail 対応の起票
- [ ] Fail のあるテストすべてに **不具合ID (`B<NNN>`) が紐づけられている**
- [ ] 該当する `bug.json` と `bug-report.md` が作成されている
- [ ] `status.json` の `phases.bug_fix.open_bugs` に bug_id が登録されている
- [ ] 不具合IDが **プロジェクト全体でユニーク** である (他機能のバグ ID と重複していない)

### D. カバレッジ実測の記録
- [ ] 単体テストのカバレッジ実測値が記入されている
- [ ] カバレッジ目標と実測の比較 (達成 / 未達) が記録されている
- [ ] 未達の場合、ユーザ確認済み (`decisions.md`)

### E. 実行コマンド・環境
- [ ] 実行コマンド、環境 (OS / 言語 / DB 等)、実施日時 が記録されている

### F. status.json の正しさ
- [ ] `phases.testing.subtasks.{unit,integration,e2e}_test.status = "completed"`
- [ ] `phases.testing.status = "completed"`
- [ ] `current_phase` の遷移先が決まっている (`bug_fix` または 次フェーズ/機能完了)

### G. 横断一貫性 (バッチ時の必須チェック)
- [ ] **全機能のテスト結果ドキュメント書式が揃っている** (サマリ表・詳細表のカラム順、所要時間記録の有無 等)
- [ ] **不具合IDがプロジェクト全体で一意** (`B001..BNNN` が重複していない)
- [ ] **COMMON モジュールのテストも実行されている** (該当時) し、結果が記録されている
- [ ] 同種の Fail (例: 同じ COMMON モジュールの欠陥) が複数機能で発生していないか、発生している場合は1件の bug_id にまとめられているか

## 手順

1. インプット (テスト設計 + 実テストコードのファイル一覧) を Read。
2. アウトプット (テスト結果3ドキュメント + bug.json + status.json) を Read。
3. **テストID 突合**: テスト設計の各 ID を集合 A、結果ドキュメントに出現する ID を集合 B として A ⊂ B を機械的に確認。差集合 (A − B) が空であること。
4. 結果ステータスを集計: `pass`, `fail`, `skip` の件数と、それ以外の値 (空欄、`未実施`、`実施不可` 等) の件数。後者が 0 件であること。
5. Fail テストごとに対応する bug_id があるか確認。
6. 本スキルディレクトリ配下の `resources/review.md` から `docs/06_reviews/<FID>/testing-review.md` を生成。
7. `status.json` の `phases.testing.review` を更新。
8. 戻り値の `proceed_to`:
   - `open_bugs` が空 → `done` (次機能 or プロジェクト完了)
   - `open_bugs` が非空 → `bug_fix`

## fail 時の戻し方針

- 未実施 / 実施不可 / 空欄が残っている → `testing` を再 spawn して **実施しきる**
- Fail に対応する bug_id が起票されていない → `testing` を再 spawn して起票
- テスト設計の ID が結果に出現しない (取りこぼし) → `testing` を再 spawn
- 環境構築不能で物理的に実行できない → `open-questions.md` に追記してユーザにエスカレーション (勝手に「実施不可」で締めない)

## 判定基準
- **pass**: 全項目 OK。すべてのテストが pass/fail/skip(理由付き) のいずれかで明確に完了している
- **fail**: 1件でも NG。**特に「未実施」「実施不可」が残っている場合は即 fail**
