# implementation-review — Python + FastAPI rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `uv run ruff check .` が 0 件
- [ ] `uv run ruff format --check .` が 0 件
- [ ] `uv run mypy src` が 0 件 (strict)
- [ ] `uv lock --check` で lock 整合性 OK

### 型・スキーマ
- [ ] 全公開関数・メソッドに型注釈がある
- [ ] エンドポイントすべてに `response_model` が指定されている
- [ ] Request/Response が Pydantic BaseModel になっており dict / Any 戻りでない
- [ ] DB モデルが `Mapped[T]` スタイルで書かれている

### 非同期と I/O
- [ ] async 関数内で sync ライブラリ (`requests` / sync DB driver / `open()`) を直接呼んでいない
- [ ] HTTP 呼び出しは `httpx.AsyncClient` 経由
- [ ] DB は SQLAlchemy async session 経由

### レイヤ分離
- [ ] Router にビジネスロジックがない (Service へ委譲)
- [ ] Service が直接 SQL を書かず Repository 経由
- [ ] Repository が `commit` / `rollback` していない (Service の責務)
- [ ] トランザクション境界が Service 層で明示されている

### エラー・ログ
- [ ] `HTTPException` は router か exception handler でのみ raise
- [ ] ドメイン例外は `AppError` 派生
- [ ] `except Exception: pass` などの握りつぶしがない
- [ ] `print()` / 標準 logging を使っていない (`structlog` 経由)

### セキュリティ
- [ ] secrets / API キーがコードに埋め込まれていない (`pydantic-settings` 経由)
- [ ] 認可 dependency が必要な全エンドポイントに付与されている
- [ ] SQL は ORM 経由か parameterized query (raw SQL の文字列結合がない)
- [ ] PII (個人情報) がログに出ていない

### パフォーマンス
- [ ] N+1 クエリが発生していない (`selectinload` / `joinedload` 検討済み)
- [ ] バックグラウンドで重い同期処理を待っていない (必要なら BackgroundTasks / Celery)

### 横断 (cross) モード追加観点
- [ ] 同等の Pydantic schema が複数機能で別名定義されていないか (共通化 → `schemas/common/`)
- [ ] 同じ dependency が複数機能で再実装されていないか (共通化 → `core/dependencies.py`)
- [ ] エラーレスポンス形式 (Problem Details) が全機能で一貫しているか
- [ ] ログイベント名の命名規則が全機能で揃っているか
