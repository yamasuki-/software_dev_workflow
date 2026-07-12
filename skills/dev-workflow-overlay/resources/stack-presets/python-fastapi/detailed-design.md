# detailed-design — Python + FastAPI rules

## ADD
- API エンドポイントは `APIRouter` 単位で機能 (FID) または resource ごとに分割し、`api/v<n>/<resource>.py` に配置する
- Request/Response はすべて Pydantic v2 BaseModel として `schemas/` に定義する
  - Request DTO: `<Action><Resource>Request` (例: `CreateUserRequest`)
  - Response DTO: `<Resource>Response` または `<Action><Resource>Response`
  - 共有 DTO は `schemas/common/` に置く
- Service 層 / Repository 層を分離する
  - Routes → Service → Repository → DB の順で呼び出す
  - Routes は HTTP 入出力変換のみ。ビジネスロジックを書かない
  - Service は async 関数の集合。状態を持たない (DI で session を受ける)
  - Repository は SQLAlchemy session を受け取りクエリのみ実行
- DB モデルは SQLAlchemy 2.0 Declarative + `Mapped[T]` スタイルで `models/` に定義する
- 依存注入は FastAPI `Depends` を使い、`core/dependencies.py` に共通 dependency を集約する
- 認可は `Annotated[User, Depends(require_role(...))]` のような dependency で表現し、各エンドポイントの型シグネチャから可視化する

## OVERRIDE
- 「機能設計シーケンス図にレイヤを記載」→ Mermaid sequenceDiagram で `Client / Router / Service / Repository / DB` の 5 lane を必須とする
- 「DB 設計を ER 図で記述」→ 設計の正は **Mermaid erDiagram (主要 FK) + カラム定義表** (型 / NOT NULL / PK / FK / index / 制約)。SQLAlchemy モデルコードは **実装フェーズで本設計から作成** する (設計書にコードは書かない)

## DISABLE
- 「画面遷移図必須」(API only プロジェクトでは無効化。フロントエンドが別リポジトリの場合)

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/api-schema.yaml`
  - 該当機能のエンドポイントだけを切り出した OpenAPI スニペット (FastAPI が出す全 OpenAPI から該当パスを抽出)
- `docs/02_detailed_design/<FID>/pydantic-schemas.md`
  - 主要 request/response の項目説明、バリデーションルール、サンプル JSON。**表形式で記述 (Pydantic コードは書かない。実装フェーズで本仕様から作成)**
- `docs/02_detailed_design/COMMON/dependencies.md`
  - 共通 dependency (認証/認可/ページネーション/トランザクション) の一覧と使い方

## REVIEW_EXTRAS
- 全エンドポイントに `response_model` 引数が指定されているか (response 型推論任せにしない)
- Path / Query / Body パラメータが Pydantic 型または `Annotated` で型注釈されているか
- Service / Repository 層を経由せず Router 内で直接 SQLAlchemy を触っていないか
- トランザクション境界が Service 層で明示されているか (`async with session.begin():`)
- 認可 dependency が必要な全エンドポイントに付いているか (公開エンドポイント以外)
