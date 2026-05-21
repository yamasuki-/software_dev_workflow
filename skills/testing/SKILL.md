---
name: testing
description: テスト設計に基づき単体・結合・E2Eテストを実行して結果を記録する。Failしたケースは不具合として登録し、`bug-fix` フェーズに引き継ぐ。`dev-workflow` から `current_phase = testing` のときに呼ばれる、または「<機能ID> のテストを実行して」と言われた時に使用する。
---

# testing — テスト実行スキル

## サブエージェント実行前提

このスキルは原則 `dev-workflow` オーケストレータから **別エージェント (サブエージェント) として spawn される** ことを想定する。

重要:
- コンテキストはフレッシュ。必要情報はブリーフとファイルから取得すること。
- スコープは原則 **1機能 (`<FID>`) ずつ**、もしくはブリーフで指定された層 (単体のみ等)。
- 状態は必ず `.dev-workflow/features/<FID>/status.json` および新規 `bugs/<BID>.json` に書き戻す。
- 不具合IDは **プロジェクト全体で一意**。`project.json` の `next_bug_id` (なければ 1 から) を参照・更新すること。
- 作業終了時は以下を返す: `summary` / `updated_files` / `open_questions` / `next_action` / `blockers`。戻り値に **検出した bug_id の一覧** を含めること。
- 重要度 high の不明点は即時 ユーザに確認 (チャットで質問)、軽微なものは `open-questions.md` に追記。

## 役割
テスト設計に基づきテストを実行し、結果を記録する。Fail があれば不具合票として登録し、`bug-fix` フェーズへ移行する。

## 成果物 (`docs/04_test_results/<FID>/`)

| ファイル                       | テンプレート                                       |
| ------------------------------ | -------------------------------------------------- |
| `unit-test-result.md`          | `templates/test-results/unit-test-result.md`       |
| `integration-test-result.md`   | `templates/test-results/integration-test-result.md`|
| `e2e-test-result.md`           | `templates/test-results/e2e-test-result.md`        |

## 手順

### Step 1 : 前提読み込み

- `docs/03_test_design/<FID>/unit-test.md` / `integration-test.md` / `e2e-test.md`
- `.dev-workflow/features/<FID>/status.json`

### Step 2 : 単体テストの実行

1. プロジェクトのテストランナーで単体テストを実行 (例: `pytest`, `npm test`, `go test` 等)。コマンドはプロジェクト固有なので不明なら確認。
2. 結果を `docs/04_test_results/<FID>/unit-test-result.md` に記録:
   - 実行コマンド、環境、実施日時
   - サマリ表 (計画/実行/Pass/Fail/Skip)
   - 詳細表 (テストID単位の Pass/Fail と所要時間)
   - カバレッジ実測値 (設計時の目標と比較)
3. Fail があれば各テストIDごとに不具合票を起こす (後述)。

### Step 3 : 結合テストの実行

1. 結合テストを実行 (DBは実環境/それに近い環境で)。
2. 結果を `integration-test-result.md` に記録。
3. Fail は不具合票へ。

### Step 4 : E2E テストの実行

1. E2Eテストを実行。UI自動化があれば自動、無ければ手動でシナリオを再現。
2. 手動の場合、各ステップで観察した内容を簡潔に記載。
3. 結果を `e2e-test-result.md` に記録。
4. Fail は不具合票へ。

### Step 5 : 不具合票の起票

Fail 1件につき以下を実施:

1. `templates/progress/bug.json` をコピーして `.dev-workflow/features/<FID>/bugs/B<連番3桁>.json` を作成。
2. `templates/bug-report.md` をコピーして `docs/05_bug_reports/B<連番3桁>.md` を作成し、再現手順・期待結果・実際の結果・ログを記入 (この時点では原因/修正欄は空欄)。
3. `status.json` の `phases.bug_fix.open_bugs` 配列に bug_id を追加。
4. テスト結果ドキュメントの該当行の「関連バグID」欄に `B<番号>` を記入。

不具合IDの連番は **プロジェクト全体で一意** にする (機能をまたいで `B001, B002, ...`)。`project.json` に `next_bug_id` カウンタを置いてもよい。

### Step 6 : 進捗確定 (本フェーズ作業の完了)

`status.json` の `phases.testing.status = "completed"` まで進める。
**`current_phase` はまだ進めない** (testing-review の pass を待つ)。

戻り値で「testing-review を spawn してほしい」とオーケストレータに伝える。

testing-review の結果に基づき、オーケストレータが次フェーズを決定:
- `open_bugs` が空 → 次の機能 or プロジェクト完了
- `open_bugs` が非空 → `bug_fix` フェーズへ

**重要**: 次フェーズに進めるのは **`testing-review` の pass を確認した後** だけ。特に「未実施」「実施不可」が結果に残っている場合、testing-review は fail を返すので必ず再走になる。

## チェックリスト

- [ ] 単体/結合/E2E の3結果ドキュメントすべてが作成済み
- [ ] 設計上のテストIDすべてに対し、結果が記録されている (Skip も理由付きで)
- [ ] カバレッジ実測値が記入され、目標との比較ができている
- [ ] Fail の全件で不具合票 (`.dev-workflow` 側の json と `docs/05_bug_reports/` 側の md 両方) が起票済み
- [ ] `status.json` 更新済み
