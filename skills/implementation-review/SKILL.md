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

**インプット = 詳細設計5ドキュメント + テスト設計3ドキュメント + テストコード**、**アウトプット = プロダクトコード** の整合を確認する。
**ユーザ指示の通り「インプットとなる前工程の成果物通りであるか」を必ず確認する**。

本スキルは **2 段ゲート** の一部として動作する: `mode=per_feature` を全機能分→ `mode=cross` を 1 回。

## 実行モード

| mode          | 対象スコープ      | 評価する節          | 保存先                                              |
| ------------- | ----------------- | ------------------- | --------------------------------------------------- |
| `per_feature` | 単一機能 `<FID>`  | §「個別チェック」(A〜H) | `phases.implementation.review.per_feature`          |
| `cross`       | 全機能            | §「横断チェック」(I〜J) | `phases.implementation.review.cross`                |

レビュー票:
- `per_feature`: `docs/06_reviews/<FID>/implementation-review-per-feature.md`
- `cross`: `docs/06_reviews/_cross/implementation-cross-review.md`

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                | アウトプット                                                |
| --------------------------------------------------------- | ----------------------------------------------------------- |
| `docs/02_detailed_design/<FID>/*.md` (5種)                | `src/...` (プロジェクト固有のプロダクトコード)              |
| `docs/03_test_design/<FID>/*.md`                          | `.dev-workflow/features/<FID>/tasks/<TID>.json` (全タスク)  |
| `tests/{unit,integration,e2e}/<FID>/...` (既存失敗テスト) | `.dev-workflow/features/<FID>/status.json`                  |

## チェックリスト

### 個別チェック (mode = per_feature) — 単一機能について検証

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

---

### 横断チェック (mode = cross) — 全機能を見渡して検証

### I. 横断一貫性とコード重複検出 (バッチ時の必須チェック)
- [ ] **モジュール構成の統一**: ディレクトリレイアウト、ファイル命名、レイヤ分割が機能をまたいで一貫
- [ ] **エラー処理パターンの統一**: 例外クラス階層、エラーレスポンス書式が機能をまたいで一貫
- [ ] **ログ・テレメトリの形式統一**: ログレベル、構造化フィールド、メトリクス命名が一貫
- [ ] **コード重複の検出**: 複数機能で同様のロジック (バリデーション・型変換・データアクセスパターン) が重複していないか
  - 重複があれば `COMMON` への切り出しを推奨し `issues[]` に記録
- [ ] **既存 COMMON モジュールが使われているか**: `src/common/` (または COMMON 配置) のモジュールを各機能が import しているか、独自再実装していないか

### J. 共通化の機会 (バッチ時)
- [ ] `open-questions.md` の `[COMMON 候補]` を評価
- [ ] 切り出し推奨が出た場合は具体的なモジュール名/責務を `issues[]` に明記
- [ ] 判断結果を `decisions.md` に記録

## 手順

1. インプット (詳細設計 + テスト設計 + テストコード) を Read。
2. アウトプット (プロダクトコード + status.json + tasks/) を確認。
3. **テストランナーを実行** して全件 Pass を実機確認 (Trust but verify)。
4. テストコードの不変性を確認 (test-implementation 時のファイル一覧と比較)。
5. プロダクトコードと詳細設計の対応を逐項目チェック。
6. 本スキルディレ