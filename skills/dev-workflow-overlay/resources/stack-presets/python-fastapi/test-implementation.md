# test-implementation — Python + FastAPI rules

## ADD
- `pytest` + `pytest-asyncio` (`asyncio_mode = "auto"`) を使う
- API 層は `httpx.AsyncClient(transport=ASGITransport(app=app))` でテストする (TestClient は使わない)
- DB を伴うテストは **トランザクション + savepoint ロールバック** パターンで分離する
  - `conftest.py` で session fixture を作り、テスト終了時に必ず rollback
- フィクスチャは以下の階層で配置:
  - `tests/conftest.py`: 全テスト共通 (engine, app, settings override)
  - `tests/<層>/conftest.py`: 層固有 fixture
  - 機能固有 fixture は `tests/<層>/<FID>/conftest.py`
- テストデータ生成は **factory-boy** または ファクトリ関数 (`make_user(**overrides)` 形式) を使う
- 外部依存 (HTTP 通信、メール、Stripe など) は `pytest-mock` の `mocker.patch` でモックする
- E2E では実際の DB / Redis を立てる (docker compose の test 用スタック)
- テストファイル命名: `test_<モジュール名>.py` または `test_<シナリオ>.py`
- テスト関数命名: `test_<対象>_<前提条件>_<期待結果>` (例: `test_create_user_with_duplicate_email_returns_409`)

## OVERRIDE
- 「テストコード作成後に Red 確認」→ pytest 実行時 `--strict-markers` を付け、`-x` で初回失敗時に止める。Red 確認ログには **失敗内容と理由** を必ず記載

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `tests/conftest.py` (engine / app / session fixture)
- `tests/factories.py` または `tests/factories/<resource>.py`
- `docs/04_test_results/<FID>/red-confirmation.md` (Red 確認時の pytest 出力を貼付)

## REVIEW_EXTRAS
- 全テストが `async def` で書かれているか (FastAPI 経路のテストの場合)
- 同期 fixture と async fixture が混在していないか
- DB を触るテストが他テストに影響を残していないか (`pytest-xdist` で並列実行して再現性確認)
- モック対象が「外部依存」だけになっているか (内部ロジックを過剰にモックしていないか)
- Red 確認時、各テストの **失敗理由** が「未実装による NotImplementedError / ImportError」など想定通りであるか
