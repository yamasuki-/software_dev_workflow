# Stack Config — Python + Django (+ DRF)

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       Python 3.13 (3.12 でも可)
- パッケージマネージャ:       uv (https://docs.astral.sh/uv/)
- 仮想環境:                   uv 管理 (`.venv/`)
- 依存解決:                   `pyproject.toml` + `uv.lock` をコミット

## フレームワーク
- バックエンド:               Django 5.x (LTS 5.2 を推奨)
- API:                        Django REST framework 3.15+
- 認証:                       django.contrib.auth + djangorestframework-simplejwt または allauth
- 管理画面:                   django.contrib.admin (内部運用ツールとして活用)
- ORM:                        Django ORM (Django 5 の async ORM 対応箇所は積極活用)
- DB:                         PostgreSQL 16+
- マイグレーション:           Django migrations (各 app の `migrations/`)
- 非同期タスク:               Celery + Redis または django-q2
- キャッシュ:                 django-redis

## コーディング規約 (スタック標準)
- フォーマッタ:               `ruff format` (Black 互換)
- リンタ:                     `ruff check` (E, F, I, B, UP, DJ ルール有効化)
- 型チェッカ:                 `mypy` (django-stubs と djangorestframework-stubs を併用)
- 命名規則:                   PEP8 準拠。app 名は snake_case 単数形
- 型注釈の必須度:             views / serializers / services の公開関数に必須
- ディレクトリレイアウト規約: app 単位で分割

### 推奨ディレクトリレイアウト
```
src/
└─ <project_name>/
   ├─ settings/         ← base.py / dev.py / prod.py / test.py
   ├─ urls.py
   ├─ wsgi.py / asgi.py
apps/
├─ <app_name>/
│   ├─ models.py
│   ├─ serializers.py
│   ├─ views.py (ViewSet)
│   ├─ services.py        ← ビジネスロジック
│   ├─ urls.py
│   ├─ admin.py
│   ├─ migrations/
│   └─ tests/
│      ├─ test_models.py
│      ├─ test_serializers.py
│      ├─ test_views.py
│      └─ test_services.py
```

## テスト基盤 (スタック標準)
- テストランナー:             pytest + pytest-django
- DB:                         `--create-db` / `--reuse-db` を CI で使い分ける
- フィクスチャ:               pytest fixtures (`conftest.py`)。Django の TestCase は使わない
- ファクトリ:                 factory-boy + faker
- API クライアント:           DRF の `APIClient`
- モック:                     pytest-mock
- 命名規則:                   `test_<対象>_<シナリオ>_<期待結果>`
- カバレッジ計測ツール:       coverage[toml] via pytest-cov
- カバレッジ目標 (スタック既定): 行 85% / 分岐 80%

## ロギング / 監視 (スタック標準)
- ログライブラリ:             Django LOGGING + structlog (django-structlog)
- 構造化ログ形式:             JSON (本番)
- リクエストロガ:             django-structlog の middleware で request_id を付与
- メトリクス:                 django-prometheus
- エラートラッキング:         Sentry (sentry-sdk[django])

## エラー処理パターン (スタック標準)
- 例外階層:                   `apps/<app>/exceptions.py` にドメイン例外を定義
- DRF 例外ハンドラ:           `EXCEPTION_HANDLER` を上書きし RFC 7807 形式に変換
- バリデーション:             serializer の `validate_<field>` / `validate` メソッドで完結させる

## CI/CD ツール
- CI:                         GitHub Actions
- 必須チェック:
  1. `uv sync --frozen`
  2. `uv run ruff check .`
  3. `uv run ruff format --check .`
  4. `uv run mypy .`
  5. `uv run python manage.py makemigrations --check --dry-run` (未生成マイグレ検出)
  6. `uv run pytest --cov --cov-branch --cov-fail-under=80`

## ADD (スタック由来の追加ルール)
- ビジネスロジックは views / serializers ではなく `services.py` に集約する (fat-model / fat-view を避ける)
- 直接 `Model.objects` を views から呼ばず、service 経由でクエリする (テスタビリティ確保)
- migration は **必ず手動で内容を確認** してからコミット (auto generation の罠に注意)
- settings は環境別 (base / dev / prod / test) に分割し、機密は環境変数経由
- N+1 を避けるため `select_related` / `prefetch_related` を明示

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「DB 設計を ER 図で記述」→ Django Model 定義を真とし、ER 図は主要 FK 関連のみ Mermaid で記述
- 「機能ごとに API スキーマを定義」→ DRF Spectacular で OpenAPI を自動生成し、それを成果物とする

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/api-schema.yaml` (drf-spectacular で生成)
- `apps/<app>/migrations/<番号>_<FID>_*.py` (DB スキーマ変更時)
- `docs/02_detailed_design/<FID>/serializers.md` (主要 serializer の項目説明)

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- views / serializers にビジネスロジックを書いていないか (service 層に出ているか)
- N+1 が発生していないか (django-debug-toolbar や django-silk で確認)
- migration が auto-generation のままで意図せぬ変更が含まれていないか
- secrets が settings に直書きされていないか
- DRF permission_classes が全 ViewSet に明示されているか (デフォルト依存しない)
