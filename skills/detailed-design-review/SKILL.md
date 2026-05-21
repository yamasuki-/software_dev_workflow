---
name: detailed-design-review
description: detailed-design フェーズ完了時に、機能の詳細設計成果物が基本設計 (インプット) どおりかを検証する専用レビュースキル。5種ドキュメント (UI/機能/状態/DB/シーケンス) の整合性と相互一致を確認し pass/fail を返す。dev-workflow オーケストレータから機能ごとに自動で spawn される。
---

# detailed-design-review — 詳細設計レビュー

## サブエージェント実行前提

- `dev-workflow` から **対象機能の detailed-design 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `result` / `issues[]` / `next_action` / `updated_files`。
- レビュー票は `docs/06_reviews/<FID>/detailed-design-review.md`。

## 役割

**インプット = 基本設計4ドキュメント + 要件**、**アウトプット = 詳細設計5ドキュメント** の整合性を確認する。

## レビュー対象 (インプット ↔ アウトプット)

| インプット                                                    | アウトプット                                              |
| ------------------------------------------------------------- | --------------------------------------------------------- |
| `docs/01_basic_design/feature-list.md` の対象機能行           | `docs/02_detailed_design/<FID>/ui-design.md`              |
| `docs/01_basic_design/system-overview.md`                     | `docs/02_detailed_design/<FID>/functional-design.md`      |
| `docs/01_basic_design/system-architecture.md`                 | `docs/02_detailed_design/<FID>/state-transition.md`       |
| `docs/01_basic_design/non-functional.md`                      | `docs/02_detailed_design/<FID>/db-design.md`              |
| `docs/requirements/*.md` (該当箇所)                           | `docs/02_detailed_design/<FID>/sequence.md`               |

## チェックリスト

### A. 成果物の存在
- [ ] 5ドキュメントすべて存在 (該当なしの場合は `.md` 内に「該当なし」と理由が明記されている)
- [ ] Mermaid 図が必要箇所すべてに描かれている (状態遷移/ER図/シーケンス は必須)

### B. ID 体系
- [ ] 画面ID `S<連番3桁>` がユニーク
- [ ] サブ機能ID `<FID>-<連番>` がユニーク
- [ ] 状態ID/イベントID が規約通り
- [ ] ユースケースID (`UC01`...) がユニーク
- [ ] エラーID (`E001`...) がユニーク

### C. 基本設計との整合 (インプット ↔ アウトプット)
- [ ] 機能の概要が `feature-list.md` の機能行と一致
- [ ] 機能の依存関係が `feature-list.md` の `depends_on` と一致
- [ ] 採用技術が `system-architecture.md` の構成要素表と整合
- [ ] 非機能要件 (`non-functional.md`) が詳細設計に反映 (例: 性能要件が DB 設計のインデックスに、セキュリティ要件が機能設計の例外処理に)
- [ ] 要件定義書の該当箇所と矛盾がない

### D. 5ドキュメント間の整合 (アウトプット内整合)
- [ ] **UI項目 ↔ DB カラム**: UI で入力する項目に対応する DB カラムが存在
- [ ] **状態遷移 ↔ 機能設計**: 状態遷移の各遷移が機能設計の処理ロジックでカバーされている
- [ ] **シーケンス ↔ アーキテクチャ**: シーケンス図の登場要素 (フロント/API/DB/外部) がアーキ構成要素として定義済み
- [ ] **機能設計の例外 ↔ UI のエラーメッセージ**: エラーID と UI 上の表示メッセージが対応している (UI ありの場合)

### E. 完全性
- [ ] 機能設計の各サブ機能に「入力」「出力」「処理ロジック」が記入されている
- [ ] 機能設計の例外/エラー処理が ID 付きで列挙されている
- [ ] DB 設計の各テーブルに「カラム定義」「インデックス」「制約」「データライフサイクル」が記入されている (永続化ありの場合)
- [ ] シーケンス図に正常系・代表的な異常系の両方がある

### F. ユーザ確認の完了
- [ ] 本機能関連の `open-questions.md` の open 項目がない
- [ ] `decisions.md` に本機能の判断が追記されている

### G. USDM 形式の場合の追加チェック
- [ ] 仕様 (`S-###-##`) がサブ機能ID/テストケースIDのいずれかにマップされている

## 手順

1. インプット (基本設計4ドキュメントの関連箇所、要件の該当箇所) を Read。
2. アウトプット5ドキュメントを Read。
3. 上記チェックリストを判定。
4. `templates/review/review.md` から `docs/06_reviews/<FID>/detailed-design-review.md` を生成。
5. `status.json` の `phases.detailed_design.review` を更新:
   - `iteration += 1`, `last_result`, `last_reviewed_at`, `status = "completed"`
6. 戻り値を返す。

## fail 時の戻し方針

- 整合性違反 → `detailed-design` を再 spawn (該当ドキュメントの修正)
- 基本設計側の問題が露呈した → `basic-design` まで戻す必要があるため、`open-questions.md` に追記してユーザ確認

## 判定基準
- **pass**: 全項目 OK (該当なし含む)
- **fail**: 1件でも NG
