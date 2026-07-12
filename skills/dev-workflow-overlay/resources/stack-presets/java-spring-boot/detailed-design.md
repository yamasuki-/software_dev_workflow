# detailed-design — Java + Spring Boot rules

## ADD
- パッケージ構成は `web / service / domain / repository / infra / config` の 6 層を基本
  - `web` は Controller と DTO のみ
  - `service` がビジネスロジックの中心
  - `domain` に Entity / Value Object / ドメイン例外
  - `repository` は Spring Data JPA インタフェース
  - `infra` は外部システム連携 (REST client / SQS / S3)
  - `config` は `@Configuration` 群
- DTO は **record** で定義する (`public record CreateUserRequest(...)`)
  - 命名: `<Action><Resource>Request` / `<Resource>Response`
  - validation アノテーション (`@NotBlank`, `@Size`, `@Email` 等) を record の構成要素に付ける
- Service の責務:
  - Transaction 境界 (`@Transactional`)
  - ドメインルールの強制
  - Repository / 外部 infra の呼び出し
- Repository:
  - Spring Data JPA インタフェースで宣言
  - 複雑クエリは `@Query` JPQL または jOOQ
  - N+1 を避ける `@EntityGraph` または fetch join を明示
- 認可:
  - method-level: `@PreAuthorize("hasRole('ADMIN')")`
  - 全体: SecurityFilterChain で URL ベース + method 二重定義
- 例外:
  - ドメイン例外を Service から throw
  - `@RestControllerAdvice` で HTTP 変換 (Problem Details)

## OVERRIDE
- 「機能設計シーケンス図」→ Mermaid sequenceDiagram で `Client / Security Filter / Controller / Service / Repository / DB / External` の lane を必須
- 「DB 設計を ER 図で記述」→ 設計の正は **Mermaid erDiagram (主要 FK) + カラム定義表** (型 / NOT NULL / PK / FK / index / 制約)。JPA Entity と Flyway SQL は **実装フェーズで本設計から作成** する (設計書にコードは書かない)

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/api-schema.yaml` (springdoc-openapi 出力)
- `docs/02_detailed_design/<FID>/jpa-entities.md` (主要 Entity のフィールド / 型 / 関連 / 制約を **表で記述**。JPA アノテーション付きコードは書かない。実装フェーズで本仕様から作成)
- `docs/02_detailed_design/COMMON/security-config.md` (Spring Security の全体設計)

## REVIEW_EXTRAS
- DTO が record で定義されているか
- Controller がビジネスロジックを含まず Service へ委譲しているか
- `@Transactional` が Service に正しく付与されているか (`readOnly = true` の指定検討)
- N+1 対策 (`@EntityGraph` / fetch join) が設計時点で議論されているか
- 認可が SecurityFilterChain + method-level の二重で漏れがないか
- Flyway migration の番号衝突がチームでハンドリングされているか (UTC タイムスタンプ命名推奨)
