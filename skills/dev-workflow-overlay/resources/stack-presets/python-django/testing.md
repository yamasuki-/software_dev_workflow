# testing — Python + Django rules

## ADD
- カバレッジは `pytest-cov` + `--cov-branch`
  - スタック既定: 行 85% / 分岐 80%
- E2E は別 compose スタックで本物の Postgres / Redis を起動
- 実行方法:
  - `make test` → 単体 + 結合
  - `make test-e2e` → E2E
  - `make coverage` → HTML レポート生成
- マイグレーションテスト:
  - 各 PR で `python manage.py migrate --plan` を実行し、未生成マイグレを検出
  - データ移行を含む migration は専用テスト (`test_migration_<番号>.py`) を書く
- 管理画面 (admin) を運用ツールとして使う場合、主要画面の smoke test を含める
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す

## OVERRIDE
- 「テスト未実施 / 実施不可は必ず理由」→ pytest の `@pytest.mark.skip(reason=...)` の reason を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/coverage.html`
- `docs/04_test_results/<FID>/junit.xml`
- データ移行テストがある場合は `docs/04_test_results/<FID>/migration-test.md`

## REVIEW_EXTRAS
- カバレッジが目標を満たしているか
- マイグレーションが未生成のままになっていないか
- E2E が本物の DB に対して実行されているか
- 管理画面を使う運用フローがある場合、admin の smoke test があるか
- flaky テスト (シグナル / Celery 由来の非同期で発生しやすい) がないか
