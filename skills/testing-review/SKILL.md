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

## auto-check 結果の取り扱い (機械チェックゲートと併走)

本レビューは LLM レビューゲートの第 2 段。直前に **auto-check** スキル (機械チェックゲート) が走り、 由来の MUST/SHOULD/MAY ツールで構文/型/lint/カバレッジ等を判定済みである。

- **auto-check MUST が fail** している場合、本レビューは spawn されない (オーケストレータがフェーズ差し戻し)。本レビューが起動した時点で MUST は pass (または skipped) と仮定してよい
- **auto-check の SHOULD warning / MAY info / skipped_missing_tools** は、オーケストレータが本レビューのブリーフに以下の形で渡してくる:

  

- 本レビューは:
  1. auto-check レポートを **必ず Read** する
  2. SHOULD warning を 1 件ずつ判定: accept (理由を decisions.md に記録) か reject (修正させる) か
  3. skipped_missing_tools は  に「ローカル環境で <tool> 未インストール、CI で必ず走ること」として確認事項として残す
  4. MAY info は参考情報。レビュー票末尾に箇条書きで列挙
  5. 機械チェックで判定済みの観点 (構文/型/lint/カバレッジ) は **再判定しない**。設計意図・命名・読みやすさ・横断一貫性などツールでは判定できない観点に集中する

## 役割

ユーザの指示どおり、テスト結果レビューでは以下を **必ず** 確認する:

1. **すべてのテストが必ず終えているか** (テスト設計の全テストIDが結果に出現すること)
2. **実施不可で終えてないか** (`未実施`, `実施不可`, `skipped (理由不明)` のような状態が残っていないこと)
3. Fail がある場合、対応する不具合票が起票され `open_bugs` に登録されているか

本スキルは **2 段ゲート** の一部として動作する: `mode=per_feature` を全機能分→ `mode=cross` を 1 回。

## 実行モード

| mode          | 対象スコープ      | 評価する節          | 保存先                                         |
| ------------- | ----------------- | ------------------- | ---------------------------------------------- |
| `per_feature` | 単一機能 `<FID>`  | §「個別チェック」(A〜F) | `phases.testing.review.per_feature`            |
| `cross`       | 全機能            | §「横断チェック」(G)    | `phases.testing.review.cross`                  |

レビュー票:
- `per_feature`: `docs/06_reviews/<FID>/testing-review-per-feature.md`
- `cross`: `docs/06_reviews/_cross/testing-cross-review.md`

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                | アウトプット                                                |
| --------------------------------------------------------- | ----------------------------------------------------------- |
| `docs/03_test_design/<FID>/{unit,integration,e2e}-test.md` | `docs/04_test_results/<FID>/{unit,integration,e2e}-test-result.md` |
| `tests/<layer>/<FID>/...` (実テストコード)                | `.dev-workflow/features/<FID>/bugs/B<NNN>.json` (Fail がある場合) |
|                                                           | `docs/05_bug_reports/B<NNN>.md` (Fail がある場合)            |
|                                                           | `.dev-workflow/features/<FID>/status.json`                  |

## チェックリスト

### 個別チェック (mode = per_feature) — 単一機能について検証

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

---

### 横断チェック (mode = cross) — 全機能を見渡して検証

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
7. `status.json` 