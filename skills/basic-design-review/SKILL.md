---
name: basic-design-review
description: basic-design フェーズ完了時に、基本設計成果物が要件定義 (インプット) どおりかを検証する専用レビュースキル。要件のカバレッジ、機能ID採番、システムアーキテクチャと非機能要件の妥当性を確認し pass/fail を返す。dev-workflow オーケストレータから自動で spawn される。
---

# basic-design-review — 基本設計レビュー

## サブエージェント実行前提

- `dev-workflow` から **basic-design 完了直後に自動 spawn** される。
- コンテキストはフレッシュ。
- 作業終了時の戻り値: `summary` / `result (pass|fail)` / `issues[]` / `next_action` / `updated_files`。
- レビュー票は `docs/06_reviews/basic-design-review.md` (反復が複数回ある場合は `-2`, `-3` のサフィックス追記)。

## 役割

**インプット = 要件定義書**、**アウトプット = 基本設計4ドキュメント + 機能一覧** の整合性を確認する。
推測で判断しない。曖昧なら fail として「要件側の確認が必要」と明記する。

## レビュー対象 (インプット ↔ アウトプット)

| インプット                        | アウトプット                                       |
| --------------------------------- | -------------------------------------------------- |
| `docs/requirements/*.md`          | `docs/01_basic_design/system-overview.md`           |
|                                   | `docs/01_basic_design/feature-list.md`              |
|                                   | `docs/01_basic_design/system-architecture.md`       |
|                                   | `docs/01_basic_design/non-functional.md`            |
|                                   | `.dev-workflow/features/<FID>/status.json` (全機能) |

## チェックリスト

### A. 要件カバレッジ
- [ ] `feature-list.md` の **カバレッジマップ** にすべての要件ID (またはUSDM R-###) が出現
- [ ] 各要件IDに対応する機能IDが少なくとも1件存在
- [ ] カバレッジマップに 「カバーする機能 = (なし)」 の行が無い

### B. 機能一覧の品質
- [ ] 機能ID `F<連番3桁>` がユニーク・連番に欠落なし
- [ ] 各機能に名称・概要・優先度・依存関係が記入されている
- [ ] 機能名は名詞句 (動詞句や文章になっていない)

### C. 基本設計4ドキュメント
- [ ] `system-overview.md` に「含む/含まない」が明示されている (空欄不可)
- [ ] `system-architecture.md` に Mermaid `flowchart` の全体構成図がある
- [ ] `non-functional.md` の各カテゴリが「未確認(要ヒアリング)」または値あり (空欄ゼロ)
- [ ] 4ドキュメントの記載内容が相互に矛盾していない

### D. 機能ごとの初期化
- [ ] 各機能の `.dev-workflow/features/<FID>/status.json` が作成されている
- [ ] 各 `status.json` で `phases.basic_design.status = "completed"`

### E. ユーザ確認の完了
- [ ] `open-questions.md` に open の項目が残っていない (本フェーズ完了の要件)
- [ ] `decisions.md` に主要決定 (機能の追加/統合/分割の根拠) が記録されている

### F. USDM 形式の場合の追加チェック
- [ ] `R-###` ↔ `F###` のマッピング行が `feature-list.md` のカバレッジマップに併記されている
- [ ] USDM 「理由」が要約されず原文引用で `decisions.md` に残っている

## 手順

1. インプット (`docs/requirements/*.md`) と `decisions.md` を Read。
2. アウトプット4ドキュメントと全機能の `status.json` を Read。
3. 上記チェックリストを上から順に判定。OK/NG/該当なし を埋める。
4. NG が1件でもあれば `result = "fail"`、すべて OK なら `result = "pass"`。
5. 本スキルディレクトリ配下の `resources/review.md` をコピーして `docs/06_reviews/basic-design-review.md` を生成 (反復2回目以降は `-2`, `-3`)。
6. `feature.json` の **全機能** の `phases.basic_design.review` を更新:
   - `status = "completed"`, `iteration += 1`
   - `last_result = "pass" | "fail"`
   - `last_reviewed_at = 現在時刻`
7. 戻り値を構成して返す。

## fail 時の戻し方針

- `feature-list.md` の カバレッジ不足 → `basic-design` を再 spawn して機能追加 or 機能修正
- `non-functional.md` の空欄 → `basic-design` 再 spawn (ユーザ確認込み)
- `system-architecture.md` の図不足 → `basic-design` 再 spawn
- ユーザ判断が必要な不整合 → ブロッカとして `open-questions.md` に追記

## 判定基準
- **pass**: チェックリスト全項目 OK (該当なし含む)
- **fail**: 1件でも NG
