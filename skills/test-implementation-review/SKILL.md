---
name: test-implementation-review
description: test-implementation フェーズ完了時に、書かれたテストコードがテスト設計どおりか、かつ全テストが必ず Fail (Red) になっているかを検証する専用レビュースキル。テスト設計のケースIDとコードの対応、Red 確認エビデンス、TDD 規律の順守を確認し pass/fail を返す。dev-workflow オーケストレータから機能ごとに自動で spawn される。
---

# test-implementation-review — テストコード作成レビュー (TDD Red 確認)

## サブエージェント実行前提

- `dev-workflow` から **対象機能の test-implementation 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `result` / `issues[]` / `next_action` / `updated_files`。
- レビュー票は `docs/06_reviews/<FID>/test-implementation-review.md`。

## 役割

**インプット = テスト設計3ドキュメント**、**アウトプット = テストコード本体 + Red 確認ログ** の対応を確認する。
**TDD Red の規律** が守られていない (Pass しているテストや構文エラーで落ちているテストがある) ことを **絶対許さない**。

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                  | アウトプット                                          |
| ----------------------------------------------------------- | ----------------------------------------------------- |
| `docs/03_test_design/<FID>/unit-test.md`                    | `tests/unit/<FID>/...`                                |
| `docs/03_test_design/<FID>/integration-test.md`             | `tests/integration/<FID>/...`                         |
| `docs/03_test_design/<FID>/e2e-test.md`                     | `tests/e2e/<FID>/...`                                 |
|                                                             | `docs/04_test_results/<FID>/<layer>-test-result.md` の **Red 確認セクション** |
|                                                             | `.dev-workflow/features/<FID>/status.json`            |

## チェックリスト

### A. 設計とコードの 1:1 対応
- [ ] テスト設計の **全テストID** に対応するテストコードが存在
- [ ] 各テストコードがテストIDを関数名 or コメントで明示している
- [ ] 設計に無いテストが勝手に追加されていない (テスト設計にもまだ無いケース)

### B. Red 確認
- [ ] テストランナーで実行した結果が `docs/04_test_results/<FID>/<layer>-test-result.md` の **Red 確認セクション** に貼り付けられている
- [ ] **すべてのテストが Fail している** (Pass しているテストがゼロ)
- [ ] Fail の理由が「対象未実装」「対象モジュール未存在」「期待値不一致」など **健全な Red** である (構文エラーや import エラーで落ちているものが無い)

### C. status.json の正しさ
- [ ] `phases.test_implementation.subtasks.{unit_test, integration_test, e2e_test}.red_confirmed = true`
- [ ] 各 subtask の `test_code_paths[]` にテストファイルが列挙されている
- [ ] `phases.test_implementation.status = "completed"`, `tdd_phase = "red_confirmed"`

### D. テストコードの品質
- [ ] AAA パターン (Arrange / Act / Assert) で書かれている (最低限の構造)
- [ ] 1テスト = 1観点 (テスト関数の中で複数の関心事を一括検証していない)
- [ ] 期待結果が観測可能な assert になっている (期待値ハードコードまたは明確な比較)

### E. 自動化不能な E2E の扱い
- [ ] 自動化できないシナリオが含まれる場合、`tests/e2e/<FID>/manual/` 等に手順書がある
- [ ] 該当する `e2e-test-result.md` に「手動シナリオで実行する旨」が明記されている

### F. ユーザ確認の完了
- [ ] テストツール選定が `decisions.md` に記録されている
- [ ] 本機能関連の `open-questions.md` の open 項目がない

## 手順

1. インプット (テスト設計3ドキュメント) を Read。
2. アウトプット (テストコード + Red 確認ログ + status.json) を確認。
3. 可能なら **テストランナーを再走** して、本当に Pass しているテストが無いか確認する (Trust but verify)。
4. チェックリスト判定。
5. 本スキルディレクトリ配下の `resources/review.md` から `docs/06_reviews/<FID>/test-implementation-review.md` を生成。
6. `status.json` の `phases.test_implementation.review` を更新。
7. 戻り値を返す。

## fail 時の戻し方針

- 設計とコードの対応漏れ → `test-implementation` 再 spawn
- Pass しているテストあり → テストが対象を本当に検証していない欠陥。`test-implementation` 再 spawn
- 構文エラー/import エラーで落ちている → `test-implementation` 再 spawn (Red ではない)
- テスト設計側の不足が露呈 → `test-design` まで戻す

## 判定基準
- **pass**: 全項目 OK
- **fail**: 1件でも NG。**特に「Pass しているテストが1件でもある」は即 fail**。
