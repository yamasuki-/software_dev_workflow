# Stack Config — Python + FastAPI

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       Python 3.13 (3.12 でも可)
- パッケージマネージャ:       uv (https://docs.astral.sh/uv/) を必須
- 仮想環境:                   uv 管理 (`.venv/` をプロジェクト直下)
- 依存解決のルール:           `pyproject.toml` + `uv.lock` を必ずコミット。バージョンは `uv lock --upgrade` 以外で動かさない

## フレームワーク
- バックエンド:               FastAPI 0.115+
- ASGI サーバ:                uvicorn (開発) / gunicorn + uvicorn worker (本番)
- ORM:                        SQLAlchemy 2.x (Declarative + Mapped[] スタイル、async)
- DB ドライバ:                asyncpg (PostgreSQL) / aiosqlite (SQLite、テスト用)
- マイグレーション:           Alembic (async 対応設定)
- バリデーション:             Pydantic v2 (BaseModel / ConfigDict)
- 設定管理:                   pydantic-settings (環境変数からの読み込み)
- ジョブ/メッセージング:      該当時 Celery + Redis、または Arq (async)

## コーディング規約 (スタック標準)
- フォーマッタ:               `ruff format` (Black 互換)
- リンタ:                     `ruff check` (E, F, I, B, UP, ANN, S, C90, N ルール有効化)
- 型チェッカ:                 `mypy --strict` (公開 API は型必須)
- 命名規則:                   PEP8 準拠。モジュール snake_case、クラス PascalCase、関数 snake_case
- 型注釈の必須度:             全公開関数・公開メソッド・公開クラス属性に必須。private (_prefix) も推奨
- ディレクトリレイアウト規約: src レイアウト (`src/<package>/`)、テストは `tests/`

### 推奨ディレクトリレイアウト
```
src/
└─ <app_name>/
   ├─ __init__.py
   ├─ main.py              ← FastAPI app 初期化
   ├─ api/                 ← ルータ (FID または resource ごとに分割)
   │  └─ v1/
   │     └─ <resource>.py
   ├─ schemas/             ← Pydantic モデル (request/response/共通 DTO)
   ├─ models/              ← SQLAlchemy モデル
   ├─ services/            ← ビジネスロジック層
   ├─ repositories/        ← DB アクセス層
   ├─ core/                ← 設定/ロギング/例外/DI
   ├─ db/                  ← session, engine, base
   └─ utils/
tests/
├─ unit/
├─ integration/
└─ e2e/
```

## テスト基盤 (スタック標準)
- テストランナー:             pytest 8.x
- async サポート:             pytest-asyncio (`asyncio_mode = "auto"`)
- HTTP クライアント:          httpx.AsyncClient (FastAPI TestClient ではなく ASGI transport 直接使用)
- フィクスチャ:               `conftest.py` で共通 fixture を一元管理
- テスト DB:                  別 schema または別 DB。トランザクションを各テストでロールバック (savepoint)
- ファクトリ:                 pytest fixture または factory-boy
- モック:                     pytest-mock (`mocker` fixture)
- 命名規則:                   `test_<対象>_<シナリオ>_<期待結果>` (例: `test_create_user_with_duplicate_email_returns_409`)
- カバレッジ計測ツール:       coverage.py via pytest-cov
- カバレッジ目標 (スタック既定): 行 85% / 分岐 80% 以上

## ロギング / 監視 (スタック標準)
- ログライブラリ:             structlog
- 構造化ログ形式:             JSON (本番) / ConsoleRenderer (開発)
- リクエストロガ:             FastAPI middleware で request_id を context に注入
- メトリクス:                 prometheus_client + starlette_exporter
- トレーシング:               opentelemetry-instrumentation-fastapi (該当時)

## エラー処理パターン (スタック標準)
- 例外階層:                   `core/exceptions.py` に `AppError` 基底クラスを置き、ドメイン別に派生
- HTTP マッピング:            `app.add_exception_handler(AppError, handler)` で一元変換
- エラーレスポンス書式:       RFC 7807 Problem Details (type / title / status / detail / instance)
- バリデーションエラー:       FastAPI 既定の 422 をそのまま使う (Pydantic ValidationError)

## CI/CD ツール
- CI:                         GitHub Actions
- 必須チェック (PR ブロック):
  1. `uv sync --frozen`
  2. `uv run ruff check .`
  3. `uv run ruff format --check .`
  4. `uv run mypy src`
  5. `uv run pytest --cov=src --cov-branch --cov-fail-under=80`
- Docker イメージ:            multi-stage build、`python:3.13-slim` ベース

## ADD (スタック由来の追加ルール)
- 全エンドポイントに対し Pydantic でリクエスト/レスポンス型を定義する (untyped 禁止)
- DB アクセスは必ず async / await で行う (sync I/O 禁止)
- 設定値は環境変数からのみ読み込む (pydantic-settings 経由、ハードコーディング禁止)
- 公開関数には docstring (Google スタイル) を付ける

## OVERRIDE (ベース指示の置き換え — スタック由来)
- ベース basic-design は「機能設計の入出力を任意の型で記述」だが、本スタックでは「Pydantic モデルとして定義し schemas/ に配置」
- ベース detailed-design は「DB 設計を ER 図で記述」だが、本スタックでは「SQLAlchemy モデル定義 + Alembic マイグレーション」で代替可

## DISABLE (ベース指示の無効化 — スタック由来)
- 「Mermaid ER 図必須」を緩和: SQLAlchemy モデル定義をもって ER 図とする (ただし主要関連は ER 図でも併記推奨)

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/api-schema.yaml` (OpenAPI、FastAPI 自動生成版を export)
- `alembic/versions/<rev>_<FID>_*.py` (DB スキーマ変更時)
- `docs/02_detailed_design/<FID>/pydantic-schemas.md` (主要 schema の用途説明)

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- 全公開関数に型注釈があるか (`mypy --strict` が pass か)
- secrets はハードコーディング禁止 (環境変数経由、pydantic-settings で受ける)
- async 関数内で sync I/O (`requests` / 同期 DB ドライバ) を呼んでいないか
- N+1 クエリが発生していないか (`selectinload` / `joinedload` の検討)
- HTTPException の status code がドメイン例外と一致しているか
