# testing — Python + FastAPI rules

## ADD
- カバレッジは `pytest-cov` で計測し `--cov-branch` を必須とする
  - スタック既定目標: 行 85% / 分岐 80%
  - 目標未達は CI で fail
- E2E は別 compose スタック (`docker compose -f compose.test.yaml up -d`) で本物の Postgres / Redis を立てて実行
- パフォーマンステストが必要な機能は `pytest-benchmark` を使う
- 実行方法を Makefile または `pyproject.toml` の `[tool.scripts]` 相当に記載:
  - `make test` → 単体 + 結合
  - `make test-e2e` → E2E (compose 起動含む)
  - `make coverage` → カバレッジレポート生成
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す
  - `unit-test-result.md` / `integration-test-result.md` / `e2e-test-result.md`
  - 各レポートに pytest の `-v` 出力 と coverage サマリを貼付

## OVERRIDE
- 「テスト未実施 / 実施不可は必ず理由を記載」→ pytest の `@pytest.mark.skip(reason=...)` の reason 文字列をそのまま結果に転記する

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/coverage.html` (HTML レポート、または coverage.xml)
- `docs/04_test_results/<FID>/junit.xml` (CI 集計用)

## REVIEW_EXTRAS
- カバレッジが目標 (行 85% / 分岐 80%) を満たしているか
- skip / xfail のテストに理由が記載されているか
- E2E が本物の DB / Redis に対して実行されているか (mock で済ませていないか)
- flaky なテスト (`pytest-rerunfailures` 必要) がないか
- 結合・E2E の実行時間がトータルで規定 (例: 5 分以内) を超えていないか
