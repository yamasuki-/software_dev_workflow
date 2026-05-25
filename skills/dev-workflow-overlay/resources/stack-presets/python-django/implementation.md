# implementation — Python + Django rules

## ADD
- ビジネスロジックは `services.py` の関数として書く (Model / View に置かない)
- views (ViewSet) は **入出力変換とパーミッションのみ** を担う薄いレイヤ
- Model の `save` / `clean` でビジネスルールを実装しない (Service で検証 → 必要なら model 保存)
- Serializer の `validate_<field>` / `validate` は **入力の整合性チェックのみ** に限定
- DB クエリ:
  - 直接 `Model.objects` を View から呼ばない (service 経由)
  - N+1 を避けるため `select_related` / `prefetch_related` を service の query 関数内で明示
  - `Queryset` を service 外に返すときは **明示的にリスト化または DTO 化** (lazy 評価が漏れて N+1 になるのを防ぐ)
- 認可:
  - ViewSet ごとに `permission_classes` を明示
  - 必要なら `get_queryset` で owner 絞り込み
- マイグレーション:
  - `python manage.py makemigrations` 後、**必ず中身を確認してからコミット**
  - データ移行は別 migration に分け `RunPython` で書く
- 設定:
  - 環境変数は `django-environ` または `pydantic-settings` 経由で読み込む
  - `DEBUG` / `SECRET_KEY` などをデフォルト値持ちで読まない (本番で誤動作する)
- ログ:
  - `import structlog; logger = structlog.get_logger(__name__)` を使う
  - イベント名 + コンテキスト形式で記録

## OVERRIDE
- ベース「コード生成時に最小実装で Green を目指す」→ 本スタックでは Serializer / Model / migration は test-implementation 段階で先に定義済みである前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は apps/ 配下に直接出力)

## REVIEW_EXTRAS
- View / Serializer / Model にビジネスロジックが漏れていないか (Service に集約)
- `Model.objects` 直接呼び出しが View にないか
- `permission_classes` が全 ViewSet に明示されているか
- N+1 が発生していないか (django-debug-toolbar / django-silk で確認)
- migration の中身が意図通りか (auto-generation 任せになっていないか)
- secrets / SECRET_KEY が settings に直書きされていないか
- `DEBUG=True` が本番設定に紛れ込んでいないか
- `print()` / 標準 logging を使っていないか
