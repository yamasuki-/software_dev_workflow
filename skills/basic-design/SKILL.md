---
name: basic-design
description: 要件定義からシステム全体の基本設計を作成する。システム概要、機能一覧 (機能ID付与)、システムアーキテクチャ、非機能要件をまとめ、以降のフェーズの単位となる機能分割を確定させる。`dev-workflow` から `current_phase = basic_design` のときに呼ばれる、または「基本設計をして」「要件を機能単位に分割して」と言われた時に使用する。
---

# basic-design — 基本設計スキル

## サブエージェント実行前提

このスキルは原則 `dev-workflow` オーケストレータから **別エージェント (サブエージェント) として spawn される** ことを想定する。直接ユーザから呼ばれる場合も同じ手順で動く。

重要:
- あなたのコンテキストは **フレッシュ** であり、過去の会話履歴は持たない。必要な情報はすべて受け取ったブリーフと、プロジェクトルート配下のファイルから取得すること。
- 状態は **必ず** `.dev-workflow/` 配下のファイルに書き戻すこと。書き戻していない情報は次回起動時に消える。
- 作業終了時は、以下の形式で 1メッセージを返すこと (250字以内):
  - `summary`: 何を完了したか
  - `updated_files`: 更新/作成したファイルの一覧
  - `open_questions`: 未解決事項 (なければ「なし」)
  - `next_action`: 推奨される次のアクション
  - `blockers`: ブロッカ (なければ「なし」)
- 重要度 high の不明点は即時 ユーザに確認 (チャットで質問) で確認、軽微なものは `open-questions.md` に追記。

## 役割
要件定義書をインプットに、**システム全体の基本設計** を作成する。最大の責務は以下の2つ。

1. システム全体の方針 (アーキテクチャ・非機能要件) を確定させる
2. 要件を **機能単位** に分割し、それぞれに一意な機能ID (`F001`, `F002`, ...) を付与する

ここで決めた機能IDが以降のすべてのフェーズの作業単位になるため、慎重に行うこと。

## 成果物 (`docs/01_basic_design/`)

| ファイル                 | 内容                                   | テンプレート (本スキル resources/ 配下)            |
| ------------------------ | -------------------------------------- | -------------------------------------------------- |
| `system-overview.md`     | システム目的・スコープ・用語・前提条件 | `resources/system-overview.md`                     |
| `feature-list.md`        | 機能一覧 (機能ID付与・要件マッピング)  | `resources/feature-list.md`                        |
| `system-architecture.md` | 全体構成図・構成要素・連携・ADR        | `resources/system-architecture.md`                 |
| `non-functional.md`      | 非機能要件 (性能/可用性/セキュリティ等) | `resources/non-functional.md`                      |

## 手順

### Step 1 : 入力の確認

1. `.dev-workflow/project.json` から `requirements.source_path` を取得。
2. 要件ファイルを Read で読み込む。
3. 要件が不足/曖昧な場合、`open-questions.md` に項目を追加し、重要なものは即時ユーザに確認 (チャットで質問)。
4. **絶対にやらないこと**: 不足要件をこちらで埋めてしまうこと。「Webアプリのようなので…」「典型的にはこうなので…」も禁止。

#### 1-A. 要件が USDM 形式の場合

要件ファイル内に `R-###` や `S-###-##` の記法が含まれる場合 (もしくは project.json で USDM が明示されている場合) は以下を遵守:

- USDM の **原本ファイルは書き換えない** (ユーザ管理のソース・オブ・トゥルース)
- 要求 (`R-###`) → 機能ID (`F###`) のマッピングは **1要求 : 1機能** か **1要求 : 複数機能** かをケースバイケースで判断し、必ず `feature-list.md` のカバレッジマップに **両方の ID を併記** する
- 仕様 (`S-###-##`) は詳細設計のサブ機能ID やテストケースIDに対応づけられるよう、`feature-list.md` の補助表に対応関係を残す
- 各機能の `decisions.md` への追記で「**理由**」を引用する際は、USDM の「理由」フィールドを **そのまま引用**。要約や翻訳をしない
- USDM の「補足」と「説明」「仕様」の間に矛盾を発見したら、`open-questions.md` に追記してユーザ確認 (勝手に取捨選択しない)

### Step 2 : ドキュメント作成

1. 4つのテンプレートを `docs/01_basic_design/` にコピー。
2. 上から順に書いていく:
   - **system-overview**: 目的、スコープ (含む/含まない明示)、用語、前提条件
   - **non-functional**: 性能/可用性/セキュリティ/拡張性/運用/UX等。要件に明記がない項目はそのまま空欄にせず、「未確認(要ヒアリング)」と記して `open-questions.md` に質問を追加。
   - **system-architecture**: 全体構成図 (Mermaid `flowchart`)、構成要素表、外部連携、配置、ADR。Mermaid は必ず使う。
   - **feature-list**: 機能IDを付け、要件マッピング表で取りこぼしがないか検証する。

### Step 3 : 機能分割のガイドライン

- 1機能の粒度: 「詳細設計5種・テスト設計3種を1〜2セッションで作成できる」程度。多くなりすぎる時は分割。
- 機能名は名詞句で短く (例: 「ユーザ登録」「在庫検索」「請求書PDF生成」)。
- 機能間の依存関係は `depends_on` に書き、可能な限り少なくする。
- カバレッジマップを必ず埋め、全要件IDがいずれかの機能IDでカバーされていることを確認。漏れがあれば機能を追加。

### Step 4 : ユーザレビュー

1. 4ドキュメントが揃ったらユーザに提示。
2. 機能一覧については特に強くレビューを促す (= 後段の作業単位なので)。
3. レビュー結果を反映。
4. `decisions.md` に確定した機能一覧の主要決定 (機能の追加/統合/分割の判断理由) を記録。

### Step 5 : 進捗の確定 (本フェーズ作業の完了)

1. `project.json` を更新:
   - `features` 配列に、機能一覧の各機能を `{id, name, summary, priority, depends_on}` で追加
   - `current_phase` は **まだ `detailed_design` に進めない** (basic-design-review の pass を待つ)
2. 各機能について、本スキルディレクトリ配下の `resources/feature.json` をコピーして `.dev-workflow/features/<FID>/status.json` を作成。`feature_id`, `name`, `summary`, `depends_on`, タイムスタンプを埋める。
3. `phases.basic_design.status = "completed"` （各機能の status.json でも）。
4. 戻り値で「basic-design-review を spawn してほしい」とオーケストレータに伝える。

**重要**: 次フェーズ (`detailed_design`) に進めるのは **`basic-design-review` の pass を確認した後** だけ。本スキル単独で `current_phase` を `detailed_design` に進めることは禁止。

## チェックリスト (基本設計完了の判定)

- [ ] `system-overview.md` の「含む/含まない」が明示されている
- [ ] `feature-list.md` の機能IDが連番でユニーク
- [ ] `feature-list.md` のカバレッジマップが全要件を網羅
- [ ] `system-architecture.md` に Mermaid 構成図がある
- [ ] `non-functional.md` の各カテゴリが「未確認」または値が書かれている (空欄ゼロ)
- [ ] 各機能の `status.json` が `.dev-workflow/features/<FID>/` に作成済み
- [ ] `open-questions.md` の `open` 項目に対し、ユーザレビューを実施済み
- [ ] `decisions.md` に主要決定が記録済み

このチェックを通過したら基本設計完了。
