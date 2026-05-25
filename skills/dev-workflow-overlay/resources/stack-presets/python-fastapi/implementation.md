# implementation — Python + FastAPI rules

## ADD
- 全公開関数 / メソッド / クラス属性に型注釈を付ける (`mypy --strict` を pass させる)
- I/O を伴う処理はすべて `async def` で記述する (sync I/O 禁止)
  - DB: SQLAlchemy async session
  - HTTP: httpx.AsyncClient
  - ファイル I/O: aiofiles
- 設定値は必ず `pydantic-settings` 経由で環境変数から読み込む (ハードコーディング禁止)
- 例外:
  - ドメイン例外は `core/exceptions.py` の `AppError` 派生クラスを使う
  - HTTP に変換する箇所は exception handler に集約 (router 内で HTTPException を直接 raise しない)
  - 想定外の例外を握りつぶさない (`except Exception: pass` 禁止)
- ログ:
  - `structlog.get_logger(__name__)` を使う
  - `logger.info("event_name", **context)` の形式で構造化ログを残す
  - PII (個人情報) はログに出さない (mask する)
- DI:
  - 共通 dependency は `core/dependencies.py` に置き `Annotated[T, Depends(...)]` で受ける
  - グローバル状態を使わない (シングルトンは DI 経由で配る)
- DB:
  - N+1 を避けるため `selectinload` / `joinedload` を明示する
  - トランザクション境界は Service 層で `async with session.begin():` で囲む
  - Repository 内で commit しない (Service 層の責務)

## OVERRIDE
- ベース「コード生成時に最小実装で Green を目指す」→ 本スタックでは Pydantic schema / SQLAlchemy model は test-implementation 段階で先に定義済みであることを前提とする (型レベルで Green が見える状態)

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は src/ に直接出力)

## REVIEW_EXTRAS
- `mypy --strict src` が pass するか
- `ruff check .` および `ruff format --check .` が pass するか
- async 関数内で sync I/O (`requests`、同期 DB ドライバ、`open()`) を呼んでいないか
- `HTTPException` を service / repository 層で raise していないか (router / exception handler のみで)
- 環境変数の直接読み込み (`os.environ[...]`) がないか (`pydantic-settings` 経由か)
- `print()` や標準 `logging` を使っていないか (`structlog` 経由か)
- secrets / API キーがコードに埋め込まれていないか
- 公開関数に docstring (Google スタイル) があるか
