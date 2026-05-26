# Stack Config — 言語/フレームワーク共通ルール

> このファイルは **全フェーズ** のサブエージェントが参照する。
> 同じ技術スタック (言語・フレームワーク・テストツール等) を使う **複数プロジェクトで再利用** することを想定。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       (例: Python 3.12 / TypeScript 5.x / Go 1.22)
- パッケージマネージャ:       (例: uv / pnpm / go mod)
- 依存解決のルール:           (例: lock ファイル必須, バージョン固定など)

## フレームワーク
- バックエンド:               (例: FastAPI / Express / Spring Boot)
- フロントエンド:             (該当時)
- ORM / クエリビルダ:         (例: SQLAlchemy / Prisma / sqlx)
- ジョブ/メッセージング:      (該当時)

## コーディング規約 (スタック標準)
- フォーマッタ:               (例: ruff format / prettier / gofmt)
- リンタ:                     (例: ruff / eslint / golangci-lint)
- 命名規則 (言語慣習):        (例: PEP8 / Airbnb JS / Effective Go)
- 型注釈の必須度:             (例: 全公開関数に必須 / TypeScript strict)
- ディレクトリレイアウト規約:

## テスト基盤 (スタック標準)
- テストランナー:             (例: pytest / vitest / go test)
- 命名規則:                   (例: test_<対象>_<シナリオ>)
- フィクスチャ作法:           (例: pytest fixtures / conftest.py)
- カバレッジ計測ツール:       (例: coverage.py / c8 / go cover)
- カバレッジ目標 (スタック既定): (例: 分岐網羅 80% 以上)

## ロギング / 監視 (スタック標準)
- ログライブラリ:
- 構造化ログ形式:             (例: JSON)
- メトリクス:                 (例: prometheus_client)
- トレーシング:               (該当時)

## エラー処理パターン (スタック標準)
- 例外階層:
- エラーレスポンス書式:       (例: RFC 7807 Problem Details)

## CI/CD ツール
- CI:                         (例: GitHub Actions)
- 必須チェック:               (例: lint / type / test / build)

## ADD (スタック由来の追加ルール)
- 例: 全エンドポイントに対し pydantic でリクエスト/レスポンス型を定義する
- 例: DB アクセスは必ず async / await で行う

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 例: ベースは「機能設計の入出力を任意の型で記述」だが、本スタックでは「pydantic モデルとして定義」

## DISABLE (ベース指示の無効化 — スタック由来)
- 例: 「Mermaid ER 図必須」を緩和: ORM のモデル定義に inline で書くため別途 ER 図を作らない

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- 例: docs/02_detailed_design/<FID>/api-schema.yaml (OpenAPI 仕様)

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- 例: 全公開関数に型注釈があるか (mypy --strict が pass か)
- 例: secrets はハードコーディング禁止 (環境変数経由)

## 自動チェック (MUST / SHOULD / MAY)

> auto-check スキルが本セクションを読み、各フェーズの直前に MUST/SHOULD/MAY を順次実行する。
> 既存のスタックプリセット (`stack-presets/<preset>/stack-config.md`) を参考に、本プロジェクトのスタックに合わせて記述する。
> 未インストールツールは skip + warn 扱いとなる。

### 全フェーズ共通

#### MUST
- (例) markdownlint-cli2 "**/*.md" "#node_modules"   # install: npm install -g markdownlint-cli2
- (例) bash ~/.claude/skills/auto-check/resources/scripts/check-mermaid.sh .   # install: npm install -g @mermaid-js/mermaid-cli

#### SHOULD
- (例) typos --no-check-filenames .

#### MAY
- (例) lychee --no-progress "**/*.md"

### <phase> 固有 (basic-design / detailed-design / test-design / test-implementation / implementation / testing)

#### MUST
- (フェーズで必須のツール。fail でゲート停止)

#### SHOULD
- (推奨ツール。warn 扱い)

#### MAY
- (任意ツール。info のみ)
