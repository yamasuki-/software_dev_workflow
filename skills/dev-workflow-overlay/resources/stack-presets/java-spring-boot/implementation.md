# implementation — Java + Spring Boot rules

## ADD
- DI は **constructor injection** のみ (Lombok `@RequiredArgsConstructor` 推奨)
  - field / setter injection 禁止
  - 全フィールドを `final` に
- DTO は record で定義 (immutable)、validation アノテーションを構成要素に付ける
- Service:
  - `@Service` + `@Transactional` (クラスレベル `@Transactional(readOnly = true)`、書き込みメソッドのみ override で readOnly = false)
  - ビジネスロジックを集約
  - Controller / Repository から直接 throw されるドメイン例外をキャッチして再 throw する場合は context を付ける
- Repository:
  - Spring Data JPA インタフェースで宣言
  - 複雑クエリは `@Query` JPQL または jOOQ
  - N+1 を避けるため `@EntityGraph` または `JOIN FETCH` を明示
- Controller:
  - 薄く保つ (DTO 変換 + Service 呼び出しのみ)
  - 例外を try-catch しない (`@RestControllerAdvice` に任せる)
  - `@Valid` で request DTO を検証
- 例外:
  - ドメイン例外 (`AppException` 派生) を Service から throw
  - `@RestControllerAdvice` で HTTP 変換 (`ProblemDetail` を返す)
  - `RuntimeException` の握りつぶし禁止
- ログ:
  - `private static final Logger log = LoggerFactory.getLogger(<Class>.class);` または `@Slf4j`
  - 構造化ログ (key/value) を意識: `log.info("user.created", kv("userId", id))`
  - PII をログに出さない
- 設定:
  - `@ConfigurationProperties` で型付き設定を受ける
  - secrets は環境変数 (`${ENV_VAR:default}`) または Vault
- 非同期:
  - virtual threads を有効化 (`spring.threads.virtual.enabled=true`)
  - `@Async` を使う場合は `Executor` を明示
- JPA:
  - `@Entity` の equals/hashCode はビジネスキー優先、ID ベースは Hibernate proxy の罠に注意
  - `cascade = ALL` の濫用禁止
  - lazy / eager の方針を明示

## OVERRIDE
- ベース「最小実装で Green」→ Java では JPA Entity / DTO / Migration が test-implementation 段階で先に定義済みである前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は src/main/java/ 配下)

## REVIEW_EXTRAS
- `./gradlew spotlessCheck` が 0 件
- `./gradlew checkstyleMain` が 0 件
- ErrorProne / SpotBugs 警告が 0 件
- DI が constructor injection か
- DTO が record で immutable か
- `@Transactional` が Service にのみ、Controller / Repository にはついていないか
- N+1 が出ていないか (integration test で 1 シナリオあたりクエリ数を測定推奨)
- ドメイン例外を握りつぶしていないか
- secrets が `application.yml` 直書きでないか
- ログに PII が出ていないか
- `cascade = ALL` の濫用がないか
- equals/hashCode が ID の lazy ロードで NPE 起こさないか
