# test-implementation — Python + Django rules

## ADD
- `pytest` + `pytest-django` を使う (`DJANGO_SETTINGS_MODULE` は `settings.test`)
- Django の `TestCase` / `unittest.TestCase` は使わず **pytest 関数スタイル** で書く
- DB を触るテストは `@pytest.mark.django_db` を付ける
  - 並列実行する場合は `@pytest.mark.django_db(transaction=True)` 要否を判断
- API テストは DRF の `APIClient` または `pytest-django` の `client` fixture
- テストデータは **factory-boy + faker** で生成。fixtures (yaml/json) は使わない
- 認証はクライアントの `force_authenticate(user=...)` で行う
- 外部依存は `pytest-mock` の `mocker.patch` でモック
- E2E は別 compose スタックで本物の Postgres / Redis を起動して実行
- テスト命名: `test_<対象>_<シナリオ>_<期待結果>`
- 各 app の `tests/` ディレクトリ配下に `test_<層>.py` (test_models / test_views / test_services / test_serializers) を配置

## OVERRIDE
- 「Red 確認」→ `pytest --tb=short -x` で初回失敗時に止める。Red 確認ログには **どのテストがどの理由で失敗しているか** を 1 行ずつ列挙

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `apps/<app>/tests/conftest.py` (app 共通 fixture)
- `apps/<app>/tests/factories.py` (factory-boy ファクトリ)
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- `pytest.mark.django_db` の付け忘れがないか (silent な fail に繋がる)
- `transaction=True` の必要性が正しく判断されているか (シグナル/トリガを使う場合のみ)
- factory-boy のファクトリが他テストの状態に依存していないか (`reset_sequences` を意識)
- Service / Model / Serializer / View の各層にテストがあるか (View だけに偏っていないか)
- Red 確認時に **未実装による失敗** だけになっているか (import error が混ざっていないか)
