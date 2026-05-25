# test-implementation — Go + chi rules

## ADD
- 単体テスト:
  - `*_test.go` をテスト対象と同じパッケージに置く
  - `package <name>_test` で外部パッケージテスト (export 経由) も併用 (公開 API 観点のテスト)
- HTTP テスト:
  - `net/http/httptest.NewRecorder()` + chi ルータで in-process テスト
  - `httptest.NewServer` は E2E 寄りでのみ使用
- DB テスト:
  - testcontainers-go で本物の Postgres を起動 (テスト用 docker)
  - 各テストで `BEGIN; ... ROLLBACK;` または truncate でクリーンアップ
  - in-memory SQLite で代用しない (sqlc が PostgreSQL 専用クエリを使う想定)
- モック:
  - シンプルなインタフェースは手書き mock を `internal/<pkg>/mock_<name>.go` に置く
  - 複雑なら gomock + go generate
- アサーション:
  - testify/require と testify/assert を使用 (require は致命、assert は継続)
- テーブル駆動テストを優先する (`tests := []struct{ name string; ... }{...}`)
- 命名:
  - ファイル: `<対象>_test.go`
  - 関数: `Test<対象>_<シナリオ>_<期待結果>` (例: `TestCreateUser_DuplicateEmail_Returns409`)
  - サブテスト: `t.Run(tc.name, func(t *testing.T) { ... })`
- `-race` を必須にする (CI で `go test -race`)

## OVERRIDE
- 「Red 確認」→ `go test ./... -run <パターン>` で対象テストだけを実行し、**FAIL 行と error メッセージ** を Red 確認ログに貼付

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `internal/<pkg>/testhelper_test.go` (テストヘルパ、export しないため `_test.go` 拡張子)
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- テーブル駆動テストが活用されているか (case を増やしやすい構造か)
- `t.Parallel()` を使うテストで race 条件が出ないか
- testcontainers コンテナがテスト終了で確実に破棄されているか (`t.Cleanup`)
- インタフェースの mock が公開 API シグネチャと一致しているか
- Red 確認時に compile error が混ざっていないか (未定義関数のシグネチャを先に定義済みであること)
