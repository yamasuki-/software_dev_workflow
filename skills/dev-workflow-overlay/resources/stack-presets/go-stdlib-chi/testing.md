# testing — Go + chi rules

## ADD
- カバレッジ: `go test -cover -coverprofile=cover.out ./...` → `go tool cover -func=cover.out`
  - スタック既定目標: 行カバレッジ 80% 以上 (Go は分岐網羅標準計測なし)
- race 検出: `-race` を必須 (CI で実施)
- E2E:
  - testcontainers-go で Postgres を起動し、ビルドした binary に対して net/http リクエストを送る
  - もしくは docker compose で起動した本物のスタックに対し別プロセスから cURL / Go client で叩く
- ベンチマーク (パフォーマンスクリティカルな箇所): `go test -bench=. -benchmem`
- 実行方法は Makefile に集約:
  - `make test` → unit + integration (`go test ./...`)
  - `make test-e2e` → E2E (compose 起動含む)
  - `make coverage` → cover.out から HTML 生成 (`go tool cover -html`)
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す
  - `go test -v -json ./... | tparse` または `gotestsum` の出力サマリを貼付

## OVERRIDE
- 「テスト未実施 / 実施不可は必ず理由」→ `t.Skip("reason")` の reason を結果に転記、`t.Skipf` も同様

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/cover.html` (HTML カバレッジレポート)
- `docs/04_test_results/<FID>/junit.xml` (gotestsum で生成、CI 集計用)
- ベンチがある場合 `docs/04_test_results/<FID>/bench.txt`

## REVIEW_EXTRAS
- `go test -race ./...` が pass
- カバレッジが目標 (80% 以上) を満たしているか
- skip テストに理由が記載されているか
- E2E が本物の DB に対して実行されているか (sqlmock で済ませていないか)
- goroutine リークがないか (uber-go/goleak の使用も検討)
- flaky テスト (タイミング依存) がないか
- testcontainers コンテナの起動・破棄でテスト時間が肥大化していないか (parallel 化検討)
