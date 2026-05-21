---
name: implementation-review
description: implementation フェーズ完了時に、プロダクトコードが詳細設計と既存テスト (インプット) どおりかを検証する専用レビュースキル。設計外の変更がないか、すべての失敗テストが Green になっているか、新規テストが勝手に追加されていないかを確認し pass/fail を返す。dev-workflow オーケストレータから機能ごとに自動で spawn される。
---

# implementation-review — 実装レビュー (TDD Green 確認)

## サブエージェント実行前提

- `dev-workflow` から **対象機能の implementation 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `result` / `issues[]` / `next_action` / `updated_files`。
- レビュー票は `docs/06_reviews/<FID>/implementation-review.md`。

## 役割

**インプット = 詳細設計5ドキュメント + テスト設計3ドキュメント + テストコード**、**アウトプット = プロダクトコード** の整合を確認する。
**ユーザ指示の通り「インプットとなる前工程の成果物通りであるか」を必ず確認する**。

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                | アウトプット                                                |
| --------------------------------------------------------- | ----------------------------------------------------------- |
| `docs/02_detailed_design/<FID>/*.md` (5種)                | `src/...` (プロジェクト固有のプロダクトコード)              |
| `docs/03_test_design/<FID>/*.md`                          | `.dev-workflow/features/<FID>/tasks/<TID>.json` (全タスク)  |
| `tests/{unit,integration,e2e}/<FID>/...` (既存失敗テスト) | `.dev-workflow/features/<FID>/status.json`                  |

## チェックリスト

### A. テスト Green の確認 (TDD Green の規律)
- [ ] テストランナーで対象機能の **全テスト** を実行 → **全件 Pass**
- [ ] 結果ログを `docs/04_test_results/<FID>/<layer>-test-result.md` に「Green 確認」セクションとして追記済み
- [ ] `status.json` の `phases.implementation.tdd_phase = "green_confirmed"`

### B. テストコードの不変性 (重要)
- [ ] **テストコードが implementation フェーズで追加/修正されていない** (test-implementation 完了時のテストと同一であること)
  - 確認方法: `tests/<layer>/<FID>/` 配下のファイル一覧と `phases.test_implementation.subtasks.*.test_code_paths[]` が一致
  - 例外: 致命的なテスト欠陥が見つかり test-implementation を再走した記録が `decisions.md` にある場合
- [ ] テスト数が test-implementation 完了時から増減していない

### C. プロダクトコード ↔ 詳細設計 の整合
- [ ] `functional-design.md` のサブ機能と実装上の関数/メソッドが対応している
- [ ] `db-design.md` のテーブル定義 (型、NOT NULL、PK、FK、デフォルト、インデックス) と実装のスキーマが一致
- [ ] `state-transition.md` の状態遷移とコード上の状態管理ロジックが一致
- [ ] `sequence.md` の各 UC の流れ (呼び出し先・タイミング) とコードが一致
- [ ] `ui-design.md` の項目・操作・遷移・バリデーションがフロント実装に反映 (UIあり)

### D. 例外/エラー処理
- [ ] `functional-design.md` の各エラーID (`E###`) に対応する例外処理コードが存在
- [ ] エラーメッセージが `ui-design.md` のメッセージ一覧と一致

### E. 非機能要件
- [ ] `non-functional.md` の性能/セキュリティ要件が実装に考慮されている (DBインデックス、入力検証、認可など)

### F. タスク管理
- [ ] `.dev-workflow/features/<FID>/tasks/` の全タスクが `completed`
- [ ] 各タスクの `tdd_target_tests` が当該タスク完了時点で Green
- [ ] 各タスクの `artifacts` に変更ファイルが列挙されている

### G. 設計外実装の禁止
- [ ] 詳細設計に書かれていない機能/エンドポイント/フィールドがコードに含まれていない
- [ ] 設計から外れた変更があった場合、`decisions.md` に判断と理由が追記され、設計ドキュメントも更新されている

### H. ユーザ確認の完了
- [ ] 本機能関連の `open-questions.md` の open 項目がない

## 手順

1. インプット (詳細設計 + テスト設計 + テストコード) を Read。
2. アウトプット (プロダクトコード + status.json + tasks/) を確認。
3. **テストランナーを実行** して全件 Pass を実機確認 (Trust but verify)。
4. テストコードの不変性を確認 (test-implementation 時のファイル一覧と比較)。
5. プロダクトコードと詳細設計の対応を逐項目チェック。
6. `templates/review/review.md` から `docs/06_reviews/<FID>/implementation-review.md` を生成。
7. `status.json` の `phases.implementation.review` を更新。
8. 戻り値を返す。

## fail 時の戻し方針

- テスト Fail 残り → `implementation` 再 spawn (該当タスクの Green 化)
- 設計と実装の不一致 → `implementation` 再 spawn (合わせる) または `detailed-design` まで戻す (`open-questions.md` で要確認)
- テストが implementation フェーズで追加/修正されていた → **重大な規律違反**。`test-implementation` まで戻し、追加分が正当か再検証
- 設計外の機能がある → `implementation` 再 spawn (除去) または設計を追加して `detailed-design` を戻す (要ユーザ確認)

## 判定基準
- **pass**: 全項目 OK
- **fail**: 1件でも NG。**特に「テストが Fail している」「テストが implementation で変更されている」は即 fail**。
