# implementation-review — Go + chi rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `gofmt -l .` が 0 件
- [ ] `goimports -l .` が 0 件
- [ ] `go vet ./...` が 0 件
- [ ] `golangci-lint run` が 0 件 (errcheck, staticcheck, gosec 等)
- [ ] `go mod tidy` の diff が出ない (依存整合)

### error と context
- [ ] error の `_` 捨てがない
- [ ] error が `%w` でラップされている (情報の欠落がない)
- [ ] sentinel error が `internal/domain/` に集約されている
- [ ] 全 public 関数の第一引数が `ctx context.Context`
- [ ] DB / HTTP 呼び出しに ctx が渡っている (タイムアウト・キャンセル可能)

### レイヤ分離
- [ ] Handler にビジネスロジックがない
- [ ] Service が SQL を直接書いていない (sqlc 経由)
- [ ] インタフェースが Service 側で定義されている (Repository 側ではない)
- [ ] domain パッケージが他層に依存していない

### 並行性
- [ ] goroutine 起動時に ctx を渡しキャンセル伝搬している
- [ ] errgroup を `errgroup.WithContext` で派生 ctx 使用
- [ ] 共有状態の mutation に sync.Mutex / channel を使っている
- [ ] `go test -race` が pass

### セキュリティ・運用
- [ ] グローバル変数を新規導入していない
- [ ] secrets が環境変数経由 (ハードコーディング禁止)
- [ ] panic がリクエスト処理中に出ない設計 (middleware recover で 500 を返す)
- [ ] sqlc 生成物が手動編集されていない

### sqlc / DB
- [ ] sqlc クエリが意図通り (EXPLAIN 等で確認したか)
- [ ] N+1 が出ていない
- [ ] 必要な index が migration に含まれている
- [ ] migration が冪等で安全に流せる

### 横断 (cross) モード追加観点
- [ ] 同等の domain 型が複数機能で別名定義されていないか
- [ ] 共通 middleware が機能ごとに重複実装されていないか
- [ ] エラーレスポンス形式が全ハンドラで一貫しているか
- [ ] ログイベント名の命名規則が揃っているか
- [ ] パッケージ間の循環 import がないか (`go list -deps` で検証)
