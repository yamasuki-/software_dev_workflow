---
name: test-design-review
description: test-design フェーズ完了時に、テスト設計ドキュメントが対応する詳細設計どおりかを検証する専用レビュースキル。詳細設計のサブ機能/例外/状態遷移/UC が漏れなくテストケースに落ちているか、双方向トレーサビリティが成立しているかを確認し pass/fail を返す。dev-workflow オーケストレータから機能ごとに自動で spawn される。
---

# test-design-review — テスト設計レビュー

## サブエージェント実行前提

- `dev-workflow` から **対象機能の test-design 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `result` / `issues[]` / `next_action` / `updated_files`。
- レビュー票は `docs/06_reviews/<FID>/test-design-review.md`。

## auto-check 結果の取り扱い (機械チェックゲートと併走)

本レビューは LLM レビューゲートの第 2 段。直前に **auto-check** スキル (機械チェックゲート) が走り、`stack-config.md` 由来の MUST/SHOULD/MAY ツールで構文/型/lint/カバレッジ等を判定済みである。

- **auto-check MUST が fail** している場合、本レビューは spawn されない (オーケストレータがフェーズ差し戻し)。本レビューが起動した時点で MUST は pass (または skipped) と仮定してよい
- **auto-check の SHOULD warning / MAY info / skipped_missing_tools** は、オーケストレータが本レビューのブリーフに以下の形で渡してくる:

  ```
  【auto-check 結果サマリ】
  - report: docs/06_reviews/<FID>/<phase>-auto-check.md
  - SHOULD warnings: N 件 (詳細はレポート)
  - MAY info: N 件
  - skipped_missing_tools: [<ツール名> ...]
  ```

- 本レビューは:
  1. auto-check レポートを **必ず Read** する
  2. SHOULD warning を 1 件ずつ判定: accept (理由を decisions.md に記録) か reject (修正させる) か
  3. skipped_missing_tools は `open-questions.md` に「ローカル環境で <tool> 未インストール、CI で必ず走ること」として確認事項として残す
  4. MAY info は参考情報。レビュー票末尾に箇条書きで列挙
  5. 機械チェックで判定済みの観点 (構文/型/lint/カバレッジ) は **再判定しない**。設計意図・命名・読みやすさ・横断一貫性などツールでは判定できない観点に集中する

## 役割

**インプット = 詳細設計5ドキュメント (対応する設計工程)**、**アウトプット = テスト設計3ドキュメント** の **完全網羅** を確認する。
ユーザ指示の通り、**「対応する設計工程通りであるか」** を最優先で検証する。

本スキルは **2 段ゲート** の一部として動作する: `mode=per_feature` を全機能分→ `mode=cross` を 1 回。

## 実行モード

| mode          | 対象スコープ      | 評価する節          | 保存先                                          |
| ------------- | ----------------- | ------------------- | ----------------------------------------------- |
| `per_feature` | 単一機能 `<FID>`  | §「個別チェック」(A〜G) | `phases.test_design.review.per_feature`         |
| `cross`       | 全機能            | §「横断チェック」(H〜I) | `phases.test_design.review.cross`               |

レビュー票:
- `per_feature`: `docs/06_reviews/<FID>/test-design-review-per-feature.md`
- `cross`: `docs/06_reviews/_cross/test-design-cross-review.md`

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                  | アウトプット                                                |
| ----------------------------------------------------------- | ----------------------------------------------------------- |
| `docs/02_detailed_design/<FID>/functional-design.md`        | `docs/03_test_design/<FID>/unit-test.md`                    |
| `docs/02_detailed_design/<FID>/state-transition.md`         | `docs/03_test_design/<FID>/integration-test.md`             |
| `docs/02_detailed_design/<FID>/sequence.md`                 | `docs/03_test_design/<FID>/e2e-test.md`                     |
| `docs/02_detailed_design/<FID>/ui-design.md` (UIあり)       |                                                             |
| `docs/02_detailed_design/<FID>/db-design.md` (DBあり)       |                                                             |
| `docs/01_basic_design/non-functional.md`                    |                                                             |

## チェックリスト (設計工程との対応)

### 個別チェック (mode = per_feature) — 単一機能について検証

### A. 単体テストの網羅 (functional-design / state-transition との対応)
- [ ] 機能設計の **各サブ機能** に対し単体テストが少なくとも 「正常系1 + 境界値1 + 異常系1」 ある
- [ ] 機能設計の **各エラーID (`E###`)** に対し単体テストが少なくとも1件ある
- [ ] 状態遷移の **各遷移 (ガード条件含む)** に対し単体テストが少なくとも1件ある
- [ ] 純粋計算ロジック (数値・境界条件) の境界値網羅

### B. 結合テストの網羅 (sequence / db-design との対応)
- [ ] シーケンス図の **各UC (正常系)** に対し結合テストが少なくとも1件ある
- [ ] シーケンス図の **各UC の代表的な異常系** に対し結合テストが少なくとも1件ある
- [ ] DB を伴う場合、永続化前後の状態を検証するテストがある
- [ ] 外部システム連携がある場合、連携シナリオごとに少なくとも1件

### C. E2E テストの網羅 (UC / 要件 との対応)
- [ ] 要件定義書のユースケース or ユーザストーリーごとに最低1シナリオ
- [ ] 業務シナリオ (複数機能をまたぐもの) が e2e-test.md に含まれる (該当時)

### D. ID 体系
- [ ] テストID `UT-<FID>-<3桁>`, `IT-<FID>-<3桁>`, `E2E-<FID>-<3桁>` が規約通り・ユニーク
- [ ] 同じIDが異なる層で重複していない

### E. テストケース記述の完全性
- [ ] 各ケースに「対象」「観点」「前提条件」「入力/手順」「期待結果」「関連設計」が記入されている
- [ ] 期待結果が **観測可能** な記述になっている (「正しく動く」のような曖昧表現を含まない)

### F. トレーサビリティ
- [ ] 各テストドキュメントの末尾トレーサビリティ表が埋まっている
- [ ] **要件 → テスト** 方向: 全要件 (USDM の場合は全 R-### / S-###) がいずれかのテストでカバーされている
- [ ] **テスト → 設計** 方向: 各テストが詳細設計のどの項目をカバーしているか書かれている
- [ ] カバーされていない要件があれば `open-questions.md` に質問が出ている

### G. カバレッジ目標
- [ ] 単体テストのカバレッジ目標値が記入されている (例: 分岐網羅 90%)
- [ ] ユーザ確認済み (`decisions.md` に記録あり)

---

### 横断チェック (mode = cross) — 全機能を見渡して検証

### H. 横断一貫性 (バッチ時の必須チェック)
- [ ] **テストID命名規約の統一**: `UT-<FID>-NNN`, `IT-<FID>-NNN`, `E2E-<FID>-NNN` がすべての機能で同一書式
- [ ] **観点記述の粒度の統一**: 「正常系/境界値/異常系」の粒度や記述スタイルが機能をまたいで一貫
- [ ] **期待結果の書き方の統一**: 期待結果が「観測可能な数値・状態」で書かれているか機能をまたいで揃っている
- [ ] **共通フィクスチャ・共通テストデータ** の重複定義がないか
- [ ] **同じバリデーション規則** (例: ユーザIDの型制約) を複数機能のテストでそれぞれ独自に定義していないか

### I. 共通化の機会 (バッチ時)
- [ ] `open-questions.md` の `[COMMON 候補]` を評価
- [ ] 共通テストヘルパー・共通フィクスチャを `COMMON` のテスト設計に集約すべきか判断
- [ ] 判断結果を `decisions.md` に記録

## 手順

1. インプット (詳細設計5ドキュメント + 要件の該当部分) を Read。
2. アウトプット (テスト設計3ドキュメント) を Read。
3. 上記チェックリスト A〜G を判定:
   - A〜C は **設計上の各要素 (サブ機能/エラー/遷移/UC) と対応テストの紐づけ表** を頭の中で作り、抜けを確認する
   - 1要素でも対応テストが見つからない場合は NG
4. 本スキルディレクトリ配下の `resources/review.md` から `docs/06_reviews/<FID>/test-design-review.md` を生成。
5. `status.json` の `phases.test_design.review` を更新。
6. 戻り値を返す。

## fail 時の戻し方針

- 網羅漏れ → `test-design` を再 spawn (該当層のテスト追加)
- 詳細設計側の不足が露呈 → `detailed-design` まで戻す必要あり (ユーザ確認推奨)
- 期待結果が曖昧 → `test-design` を再 spawn (具体化)

## 判定基準
- **pass**: 全項目 OK
- **fail**: 1件でも NG
