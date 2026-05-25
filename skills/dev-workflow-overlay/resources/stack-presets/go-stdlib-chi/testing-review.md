# testing-review — Go + chi rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが go test で実行されている
- [ ] `t.Skip` には理由が記載されている
- [ ] CI が緑 (`-race` 含めて pass)

### カバレッジ
- [ ] 行カバレッジ 80% 以上 (スタック既定)
- [ ] cover.out / cover.html が `docs/04_test_results/<FID>/` にある
- [ ] handler / service / repository それぞれにカバレッジが分散

### 並行性
- [ ] `go test -race ./...` が pass
- [ ] goroutine リークがないか (goleak での確認推奨)
- [ ] flaky テスト (タイミング依存) がないか

### 結合 / E2E
- [ ] testcontainers で本物の Postgres を起動して実行している
- [ ] sqlmock で済ませている結合テストがないか
- [ ] E2E が basic-design のユースケースを網羅しているか

### sqlc / DB
- [ ] sqlc の生成物に対するテストが含まれている
- [ ] migration 実行 → アプリ起動 → リクエスト処理 まで通っているか
- [ ] downgrade 戦略が検討されているか (必要なら逆向き migration テスト)

### 不具合
- [ ] 不具合票が作成されているか
- [ ] failing test の出力 (`go test -v -run ...`) が貼付されているか

### 横断 (cross) モード追加観点
- [ ] パッケージ間でテストカバレッジに極端な偏りがないか
- [ ] 共通ユーティリティ (`internal/util`) のテストが個別機能テストに重複していないか
- [ ] CI 全体の実行時間が許容範囲か (`-parallel` の活用検討)
- [ ] testcontainers 起動回数が過剰でないか (suite で共有可能か)
