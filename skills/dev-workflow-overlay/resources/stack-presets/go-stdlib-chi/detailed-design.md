# detailed-design — Go + chi rules

## ADD
- パッケージ構成は **Handler / Service / Repository** の 3 層を基本とし、それぞれ `internal/http/handler`, `internal/service`, `internal/repository` に置く
- ハンドラは 1 resource = 1 ファイルとし、`chi.Router` に登録するルートを `RegisterRoutes(r chi.Router, h *Handler)` 関数で集約する
- ドメイン型 (struct と error) は `internal/domain/` に置き、handler / service / repository は domain に依存する (逆は禁止)
- DB アクセスは sqlc で生成した型と関数を、Repository ラッパでテスタブルなインタフェースとして公開する
  - インタフェースは **Service 側で定義** する (依存逆転)
  - Service は `type UserRepository interface { ... }` を定義し、コンストラクタで受け取る
- HTTP リクエスト / レスポンスは別 struct (`<Action><Resource>Request` / `<Resource>Response`) として定義し、domain 型と分離する
- バリデーションは `go-playground/validator` を request struct のタグで宣言
- 認可は chi middleware (`r.Group(func(r chi.Router) { r.Use(RequireRole("admin")) ... })`) で表現
- ルート定義は `internal/http/router.go` 一箇所で全てを組み立て、構成を一目で把握できるようにする

## OVERRIDE
- 「機能設計シーケンス図にレイヤを記載」→ Mermaid sequenceDiagram で `Client / Router / Middleware / Handler / Service / Repository / DB` の 7 lane (Middleware は認可時のみ)
- 「DB 設計を ER 図で記述」→ migration SQL + sqlc queries を真とし、ER 図は主要 FK 関連のみ Mermaid で記述

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/sqlc-queries.md`
  - 該当機能で追加 / 変更する sqlc クエリの意図、パフォーマンス考慮 (index, JOIN)
- `internal/db/migrations/<timestamp>_<FID>_*.sql`
- `api/openapi.yaml` (OpenAPI を採用する場合、該当パスのスニペット)
- `docs/02_detailed_design/COMMON/middleware.md` (共通 middleware の一覧と適用順)

## REVIEW_EXTRAS
- インタフェースが Service 側で定義されているか (Repository 側に定義していないか)
- domain 層が他層に依存していないか (依存方向の検証)
- 認可 middleware が必要な全ルートに適用されているか
- Mermaid sequenceDiagram に Repository / DB lane が省略されていないか
- sqlc クエリの index が migration に含まれているか
