# Stack Config — Go + stdlib net/http + chi

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       Go 1.23 (1.22 でも可)
- モジュール管理:             go modules (`go.mod` + `go.sum` を必ずコミット)
- ツール固定:                 `tools.go` または `go.mod` の `tool` ディレクティブで dev ツールを固定

## フレームワーク
- HTTP:                       net/http (Go 1.22+ のパスパターン活用) + chi v5 (ルーティング)
- ミドルウェア:               chi/middleware + 自作
- DB:                         database/sql + pgx (PostgreSQL driver) または stdlib のみ
- クエリ:                     **sqlc** (型安全な SQL → Go コード生成) を必須
- マイグレーション:           goose または golang-migrate
- バリデーション:             go-playground/validator
- 設定管理:                   caarlos0/env または stdlib の `os.Getenv` + 自作 loader
- 構造化ログ:                 log/slog (stdlib)
- HTTP クライアント:          net/http + 自作 retry / timeout

## コーディング規約 (スタック標準)
- フォーマッタ:               `gofmt` (CI で diff チェック)、`goimports` (import 整列)
- リンタ:                     `golangci-lint` (errcheck, govet, staticcheck, gosec, revive, gofumpt, sqlclosecheck 推奨)
- 静的解析:                   `go vet ./...`
- 命名規則:                   Effective Go 準拠 (パッケージ名は小文字短く、エクスポートは PascalCase)
- ディレクトリレイアウト規約: Standard Go Project Layout を緩く適用

### 推奨ディレクトリレイアウト
```
cmd/
└─ <appname>/
   └─ main.go
internal/
├─ http/
│   ├─ router.go        ← chi ルータ組み立て
│   ├─ middleware/
│   └─ handler/
│      └─ <resource>.go ← HTTP ハンドラ
├─ service/
│   └─ <domain>.go      ← ビジネスロジック
├─ repository/
│   └─ <domain>.go      ← sqlc 生成コードのラッパ
├─ db/
│   ├─ migrations/
│   ├─ queries/         ← sqlc 入力 .sql
│   └─ sqlc/            ← sqlc 生成 .go
├─ domain/              ← struct と error 定義
└─ config/
pkg/                    ← 外部公開可能ユーティリティ (基本空)
api/                    ← OpenAPI / Proto 定義 (該当時)
```

## テスト基盤 (スタック標準)
- テストランナー:             `go test ./...`
- カバレッジ:                 `go test -cover -coverprofile=cover.out ./...`
- テストヘルパ:               testify/require, testify/assert (依存追加可)
- HTTP テスト:                net/http/httptest (chi ルータを直接呼ぶ)
- DB テスト:                  testcontainers-go で本物の Postgres を起動
- モック:                     gomock または手書きインタフェース実装 (シンプルなら手書き優先)
- 命名規則:                   `Test<対象>_<シナリオ>_<期待結果>` (例: `TestCreateUser_DuplicateEmail_Returns409`)
- カバレッジ目標 (スタック既定): 行 80% (Go は分岐網羅の計測が標準にないため行で代替)

## ロギング / 監視 (スタック標準)
- ログ:                       log/slog (JSON handler, 本番)
- request_id:                 chi/middleware.RequestID で生成、ctx 経由で全層に伝搬
- メトリクス:                 prometheus/client_golang
- トレーシング:               OpenTelemetry (該当時)

## エラー処理パターン (スタック標準)
- エラー型:                   `internal/domain/errors.go` にドメイン error 定義 (`var ErrXxx = errors.New(...)`)
- ラップ:                     `fmt.Errorf("...: %w", err)` で context を付与
- HTTP 変換:                  middleware で `errors.Is` / `errors.As` を使い HTTP status に変換
- レスポンス書式:             RFC 7807 Problem Details

## CI/CD ツール
- CI:                         GitHub Actions
- 必須チェック:
  1. `go mod download`
  2. `gofmt -l . | tee /dev/stderr | wc -l` が 0 でなければ fail
  3. `goimports -l . | tee /dev/stderr | wc -l` が 0 でなければ fail
  4. `go vet ./...`
  5. `golangci-lint run`
  6. `go test -race -cover -coverprofile=cover.out ./...`
  7. `go build ./...`

## ADD (スタック由来の追加ルール)
- DB クエリは **必ず sqlc** で生成 (raw `db.Query` の手書き禁止、テスタビリティとパフォーマンスのため)
- `context.Context` を全 API・全層の第一引数で受け回す (`ctx context.Context, ...`)
- エラーは握りつぶさない (戻り値の `error` を必ず確認、`_` で捨てない)
- `panic` はライブラリ初期化失敗時のみ。リクエスト処理中は panic させない (middleware で recover し 500 を返す)
- インタフェースは **利用側で定義** する (Go 慣習、依存逆転)
- グローバル変数禁止 (init で設定するシングルトンも避ける、DI で渡す)

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「DB 設計を ER 図で記述」→ sqlc の入力 `queries/*.sql` + migration を真とし、ER 図は主要 FK 関連のみ Mermaid で記述
- 「API スキーマ定義」→ OpenAPI を書く場合は `api/openapi.yaml` を真として oapi-codegen で型生成。書かない場合は handler コードと domain 型を真とする

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `internal/db/queries/<FID>_*.sql` (sqlc 入力)
- `internal/db/migrations/<timestamp>_<FID>_*.sql`
- `api/openapi.yaml` (OpenAPI を採用する場合)
- `docs/02_detailed_design/<FID>/sqlc-queries.md` (主要クエリの意図説明)

## 自動チェック (MUST / SHOULD / MAY)

auto-check スキルが本セクションを読み、各フェーズの直前に MUST/SHOULD/MAY を順次実行する。

### 全フェーズ共通

#### MUST
- markdownlint-cli2 "**/*.md" "#node_modules"   # install: npm install -g markdownlint-cli2
- bash ~/.claude/skills/auto-check/resources/scripts/check-mermaid.sh .   # install: npm install -g @mermaid-js/mermaid-cli

#### SHOULD
- textlint docs/**/*.md   # install: npm install -g textlint textlint-rule-preset-ja-technical-writing
- typos --no-check-filenames .   # install: cargo install typos-cli

#### MAY
- lychee --no-progress "**/*.md"   # install: cargo install lychee

### test-implementation 固有

#### MUST
- go test ./... -run XXX_NoneShould -count=1   # 一旦コンパイル確認
- go test ./... -count=1   # 期待: 全テスト Red

#### SHOULD
- (なし)

#### MAY
- (なし)

### implementation 固有

#### MUST
- gofmt -l . | tee /dev/stderr | (! grep -q .)   # diff 0 件を必須
- goimports -l . | tee /dev/stderr | (! grep -q .)   # install: go install golang.org/x/tools/cmd/goimports@latest
- go vet ./...
- golangci-lint run   # install: https://golangci-lint.run/welcome/install/

#### SHOULD
- govulncheck ./...   # install: go install golang.org/x/vuln/cmd/govulncheck@latest
- semgrep --config=p/golang --error .   # install: pip install semgrep

#### MAY
- jscpd internal/ cmd/   # install: npm install -g jscpd
- dupl -t 50 ./...   # install: go install github.com/mibk/dupl@latest

### testing 固有

#### MUST
- go test -race -cover -coverprofile=cover.out ./...
- go tool cover -func=cover.out | awk '/total:/ {gsub("%",""); if($3+0<80) {print "coverage below 80%"; exit 1}}'

#### SHOULD
- (なし)

#### MAY
- go test -bench=. -benchmem -run=^$ ./...   # ベンチがある場合のみ

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- 戻り値 error を全て受けているか (errcheck pass)
- context が全層で第一引数として渡っているか
- `panic` がリクエスト処理中に出ないか
- インタフェースが必要以上に大きくないか (Go ではインタフェース小さく分ける慣習)
- goroutine リークがないか (context キャンセル伝搬)
- secrets が環境変数経由か (ハードコーディングなし)
