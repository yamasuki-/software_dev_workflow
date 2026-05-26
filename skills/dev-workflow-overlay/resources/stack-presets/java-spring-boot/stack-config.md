# Stack Config — Java + Spring Boot

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       Java 21 (LTS、record / pattern matching / virtual threads 活用)
- ビルドツール:               Gradle 8.x (Kotlin DSL `build.gradle.kts` 推奨) または Maven
- JDK:                        Eclipse Temurin (Adoptium) 21
- 依存解決:                   Gradle Version Catalog (`libs.versions.toml`) を必須

## フレームワーク
- フレームワーク:             Spring Boot 3.4.x (Spring 6, Jakarta EE 10)
- Web:                        spring-boot-starter-web (MVC) または -webflux (Reactive)
- DI:                         Spring DI (constructor injection 必須、field injection 禁止)
- データアクセス:             Spring Data JPA + Hibernate (基本)、複雑クエリは jOOQ または JPQL
- DB:                         PostgreSQL 16+
- マイグレーション:           Flyway (`db/migration/V<番号>__<説明>.sql`)
- バリデーション:             Bean Validation (jakarta.validation) + Hibernate Validator
- セキュリティ:               Spring Security 6 (config は `@Configuration` クラスで明示)
- API ドキュメント:           springdoc-openapi (OpenAPI 自動生成)
- ロギング:                   SLF4J + Logback (JSON encoder for prod、logstash-logback-encoder)
- 設定:                       application.yml + `@ConfigurationProperties` + Profile (dev/test/prod)
- 非同期:                     `@Async` + virtual threads (Spring Boot 3.2+) または Reactor

## コーディング規約 (スタック標準)
- フォーマッタ:               Spotless (google-java-format or palantir-java-format) を Gradle plugin で
- リンタ:                     Checkstyle (Google スタイル) + SpotBugs + ErrorProne
- 命名規則:                   Java 慣習 (パッケージ全小文字、クラス PascalCase、メソッド/変数 camelCase)
- ディレクトリレイアウト規約: Spring Boot 標準 + DDD/レイヤード折衷

### 推奨ディレクトリレイアウト
```
src/main/java/<group>/<app>/
├─ App.java                  ← @SpringBootApplication
├─ config/                   ← @Configuration 群 (Security / OpenAPI / WebMvc)
├─ web/
│   ├─ controller/
│   ├─ dto/                  ← Request / Response DTO (record 推奨)
│   └─ advice/               ← @RestControllerAdvice (例外ハンドラ)
├─ service/                  ← ビジネスロジック (@Service)
├─ domain/
│   ├─ model/                ← Entity / Value Object
│   └─ exception/            ← ドメイン例外
├─ repository/               ← Spring Data JPA Repository
└─ infra/                    ← 外部連携 (REST client / Message / S3)
src/main/resources/
├─ application.yml
├─ application-dev.yml
├─ application-prod.yml
└─ db/migration/
src/test/java/<group>/<app>/
├─ <層>/...
└─ IntegrationTests.java
```

## テスト基盤 (スタック標準)
- テストランナー:             JUnit 5 (Jupiter)
- アサーション:               AssertJ (`assertThat`) を Hamcrest より優先
- モック:                     Mockito 5 + mockito-junit-jupiter (`@ExtendWith(MockitoExtension.class)`)
- DB 結合:                    Testcontainers (Postgres) + `@SpringBootTest` または `@DataJpaTest`
- WebMVC テスト:              `@WebMvcTest` + MockMvc
- REST 結合:                  `@SpringBootTest(webEnvironment = RANDOM_PORT)` + TestRestTemplate / WebTestClient
- E2E:                        Testcontainers で本物の Postgres + RestAssured
- 命名規則:                   `<クラス名>Test`、メソッドは `should_<期待結果>_when_<条件>` または 日本語 `@DisplayName`
- カバレッジ計測ツール:       JaCoCo (Gradle plugin)
- カバレッジ目標 (スタック既定): 行 85% / 分岐 75%

## ロギング / 監視 (スタック標準)
- ログ:                       SLF4J (`private static final Logger log = LoggerFactory.getLogger(...)`) または Lombok `@Slf4j`
- 構造化:                     logstash-logback-encoder で JSON 出力
- request_id:                 MDC で trace_id / request_id を伝搬 (Filter)
- メトリクス:                 Micrometer + Prometheus (`micrometer-registry-prometheus`)
- ヘルスチェック:             Actuator (`/actuator/health` / `/actuator/info`)
- トレーシング:               Micrometer Tracing (Brave or OpenTelemetry)

## エラー処理パターン (スタック標準)
- 例外階層:                   `<app>.domain.exception` にドメイン例外を定義 (`AppException` を root)
- ハンドラ:                   `@RestControllerAdvice` で `@ExceptionHandler` を集約
- レスポンス書式:             RFC 7807 Problem Details (`ProblemDetail` を Spring 6 が標準提供)
- バリデーション:             `@Valid` + `MethodArgumentNotValidException` を 400 Problem Details に変換

## CI/CD ツール
- CI:                         GitHub Actions
- 必須チェック:
  1. `./gradlew --no-daemon dependencies` (キャッシュ)
  2. `./gradlew spotlessCheck`
  3. `./gradlew checkstyleMain checkstyleTest`
  4. `./gradlew compileJava compileTestJava`
  5. `./gradlew test jacocoTestReport jacocoTestCoverageVerification`
  6. `./gradlew bootBuildImage` (必要時)

## ADD (スタック由来の追加ルール)
- DI は **constructor injection** のみ (field injection 禁止)。final フィールド + Lombok `@RequiredArgsConstructor` 推奨
- DTO は **record** を優先 (immutable)
- Entity は record にできない (JPA 制約)、`@Setter` の濫用を避け factory method 経由で生成
- `@Transactional` は Service 層のメソッドに付ける (Repository / Controller には付けない)
- N+1 を避けるため `@EntityGraph` / `JOIN FETCH` / Projection を使う
- Spring Security の SecurityFilterChain は `@Configuration` クラスで明示構築 (`WebSecurityConfigurerAdapter` 使用禁止、廃止済み)
- Flyway migration は **不可逆 forward only** (修正は別 migration で)

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「DB 設計を ER 図で記述」→ JPA Entity + Flyway SQL を真とし、ER 図は主要 FK のみ Mermaid
- 「機能設計シーケンス図にレイヤを記載」→ `Client / Filter / Controller / Service / Repository / DB` の lane を必須

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/api-schema.yaml` (springdoc-openapi の出力スニペット)
- `src/main/resources/db/migration/V<番号>__<FID>_*.sql`
- `docs/02_detailed_design/<FID>/jpa-entities.md` (主要 Entity の関連説明)

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

### detailed-design 固有

#### MUST
- (なし)

#### SHOULD
- npx --yes @redocly/cli lint docs/02_detailed_design/**/api-schema.yaml   # OpenAPI スニペットがあれば

#### MAY
- (なし)

### test-implementation 固有

#### MUST
- ./gradlew compileTestJava
- ./gradlew test --fail-fast   # 期待: 全テスト Red

#### SHOULD
- (なし)

#### MAY
- (なし)

### implementation 固有

#### MUST
- ./gradlew spotlessCheck
- ./gradlew checkstyleMain checkstyleTest
- ./gradlew compileJava compileTestJava
- ./gradlew assemble

#### SHOULD
- ./gradlew dependencyCheckAnalyze   # OWASP Dependency-Check plugin
- semgrep --config=p/java --error .   # install: pip install semgrep

#### MAY
- jscpd src/main/java   # install: npm install -g jscpd

### testing 固有

#### MUST
- ./gradlew test jacocoTestReport jacocoTestCoverageVerification

#### SHOULD
- (なし)

#### MAY
- ./gradlew pitest   # mutation testing (plugin: gradle-pitest-plugin)

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- constructor injection になっているか (field/setter injection なし)
- `@Transactional` の貼り先が Service 層か (Controller / Repository についていないか)
- N+1 が出ていないか (`@EntityGraph` 等の使用、または integration test で発見)
- Spring Security のフィルタチェーンが明示的に構築されているか
- secrets が `application.yml` 直書きでなく環境変数経由か (`${ENV:default}` パターン)
- ErrorProne / SpotBugs の警告が 0 件か
