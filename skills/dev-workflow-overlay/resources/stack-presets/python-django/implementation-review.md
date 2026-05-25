# implementation-review — Python + Django rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `uv run ruff check .` が 0 件 (DJ ルール有効)
- [ ] `uv run ruff format --check .` が 0 件
- [ ] `uv run mypy .` が 0 件 (django-stubs / drf-stubs 適用済み)
- [ ] `python manage.py makemigrations --check --dry-run` が 0 件

### レイヤ分離
- [ ] View / ViewSet にビジネスロジックが書かれていない (Service に集約)
- [ ] Serializer の `validate` がビジネスルールを判定していない (入力整合性のみ)
- [ ] Model の `save` / `clean` でビジネスルールを実装していない
- [ ] `Model.objects` を View から直接呼んでいない (Service 経由)

### 認可・セキュリティ
- [ ] 全 ViewSet に `permission_classes` を明示
- [ ] owner 絞り込みが必要な ViewSet で `get_queryset` を上書きしているか
- [ ] `DEBUG=True` が本番設定に紛れていない
- [ ] `SECRET_KEY` / DB パスワードが settings 直書きでない
- [ ] CSRF / CORS 設定が機能要件と一致しているか
- [ ] SQL injection 対策 (ORM 経由 or parameterized raw query)

### パフォーマンス
- [ ] N+1 が出ていない (`select_related` / `prefetch_related` 明示)
- [ ] Queryset を service 外に lazy のまま漏らしていない
- [ ] 重い処理を request スレッドで同期実行していない (Celery / django-q2)

### マイグレーション
- [ ] migration の中身を目視確認済み
- [ ] データ移行が必要な変更は別 migration に分離
- [ ] 後方互換 (旧コードからのアクセス可) を考慮

### ログ・例外
- [ ] `print()` / 標準 logging を使っていない (`structlog`)
- [ ] DRF EXCEPTION_HANDLER で Problem Details 形式に変換しているか
- [ ] `except Exception: pass` がない

### 横断 (cross) モード追加観点
- [ ] 同等 Serializer が複数 app で別名定義されていないか (共通化)
- [ ] permission クラスが複数 app で重複実装されていないか
- [ ] settings の値 (URL prefix / pagination / throttle) が一貫しているか
- [ ] app 間の循環 import がないか
