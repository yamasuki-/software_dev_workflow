# 人間チェックポイント (human-checkpoint) 詳細仕様

> `dev-workflow` SKILL.md §「人間チェックポイント」から参照される詳細仕様。
> checkpoint に到達した場面 (cross review pass 直後) で Read する。

**設計の最重要マイルストーン** では、ツール・LLM レビューがすべて pass しても **dev-workflow は次フェーズに進まず、ユーザに明示承認を求めて停止する**。

## いつ発生するか

| タイミング | 対象 |
|---|---|
| `requirements-review` が pass した直後 | 要件定義書 (R-### / 受入条件 / スコープ境界) の確定 |
| `basic-design` の cross review が pass した直後 | プロジェクト全体 (機能 ID / アーキ / NFR の確定) |
| `detailed-design` の cross review が pass した直後 | プロジェクト全体 (全 FID の詳細設計の確定) |

その他のフェーズ (test-design 以降) はチェックポイントなし。設計が承認された時点で人間の意思が反映済みと見なす。

## 動作

1. オーケストレータ (`dev-workflow` Skill 本体) が「cross review pass」を検出
2. **完了サマリを生成** してユーザに提示:
   - 作成 / 更新された成果物のパス一覧
   - 機能 ID (basic-design 時) / 主要決定事項
   - レビュー指摘の解決状況
   - `open-questions.md` の残件
3. **ユーザの応答を待つ** (ここで Skill のターンが終わる)
4. ユーザ応答を受けて分岐:

| ユーザ応答 | オーケストレータの動作 |
|---|---|
| `approve` / 「承認」 / 「OK」など肯定 | `decisions.md` に「YYYY-MM-DDTHH:MM:SSZ: <phase> をユーザが承認」を追記。`status.json` の `checkpoints.<phase>.status = "approved"` / `approved_at = <ts>` に更新。**§「Git 統合」に従い commit (commit 前のユーザ確認も実施)**。次フェーズへ進む |
| `<具体的な変更要求>` (例: 「F002 の機能定義を見直して」) | 該当 FID / ドキュメントを briefing に含めて該当 Agent (`basic-design` / `detailed-design`) を再 spawn。完了後に auto-check → review per_feature → review cross → 再 checkpoint |
| `skip checkpoint` / 「スキップ」 (明示のみ) | `decisions.md` に「YYYY-MM-DDTHH:MM:SSZ: ユーザにより <phase> checkpoint をスキップ」を追記。`checkpoints.<phase>.status = "skipped"` / `skipped_at = <ts>` に。次フェーズへ進む |

## サマリ提示フォーマット (オーケストレータが組み立てる)

basic-design 完了時:

```
【基本設計 完了確認 — ユーザチェックポイント】

成果物:
  - docs/01_basic_design/system-overview.md
  - docs/01_basic_design/feature-list.md   (F001, F002, F003)
  - docs/01_basic_design/system-architecture.md
  - docs/01_basic_design/non-functional.md

機能ID: F001, F002, F003  (詳細は feature-list.md)
レビュー結果: per_feature pass / cross pass
auto-check: MUST 全 pass / SHOULD warnings 0 / MAY info 2 件 (lychee による外部リンク警告)
未解決 open-questions: 0 件
主要決定事項 (今フェーズで決まったもの):
  - 言語/FW: Python 3.13 + FastAPI (decisions.md)
  - DB: PostgreSQL 16
  - ...

この内容で詳細設計に進めてよろしいですか?
- "approve" → 詳細設計フェーズに進みます
- "<具体的な指摘や変更要求>" → 該当箇所を修正のため再 spawn します
- "skip checkpoint" → 承認なしで進めます (decisions.md に記録)
```

detailed-design 完了時も同様のフォーマットで、機能ごとの詳細設計 `detailed-design.md` (+任意の ui/db) のパス、サブ機能 / I/F / 状態遷移 / DB 設計の要約を含める。

## スキップの厳格化

- **「skip checkpoint」は明示文字列のみ受理**。「いいかな」「飛ばして」のような曖昧表現は再確認する
- スキップを記録する `decisions.md` エントリには **スキップ理由** をユーザに 1 行求めて記録する (例: 「個人プロジェクトで自分が承認権限を持つため」「緊急対応中」)
- スキップは **「このフェーズの 1 回」のみ**。次フェーズの checkpoint には影響しない (project-config で恒久的に無効化したい場合は次節参照)

## project レベルでチェックポイントを無効化したい場合

開発スタイル上 checkpoint が不要なプロジェクトでは、`<PROJECT_ROOT>/.dev-workflow/rules/project/project-config.md` に以下を記述:

```markdown
## チェックポイント設定 (human-checkpoint)
- requirements: enabled
- basic-design: disabled
  - 理由: 個人プロジェクトのため
- detailed-design: enabled
```

`dev-workflow-overlay` (および overlay 経由でない素の `dev-workflow`) はこの設定を Read し、disabled となっているフェーズの checkpoint はスキップする。デフォルト (ファイルまたは本セクションが無い場合) は 3 つ (requirements / basic-design / detailed-design) とも有効。

**設定の一元管理**: checkpoint の有効/無効の設定箇所は **この `project-config.md` のみ** (single source of truth)。`project.json` の `checkpoints.<phase>` は実行状態 (`status` / `approved_at` / `skipped_at` / `history`) だけを保持し、`enabled` フラグは持たない。disabled のフェーズを通過した際は `checkpoints.<phase>.status = "skipped"` とし、`approval_notes` に「project-config で disabled」と記録する。
