# test-implementation — Java + Spring Boot rules

## ADD
- JUnit 5 (Jupiter) を使う
- AssertJ (`assertThat`) を使い、JUnit assertions / Hamcrest は使わない
- 単体テスト:
  - Service / Domain: 純粋 Java として書く (`@ExtendWith(MockitoExtension.class)` + Mockito モック)
  - Spring コンテキストを起動しない (速いから)
- WebMVC テスト:
  - `@WebMvcTest(<Controller>.class)` + MockMvc
  - Service は `@MockBean` でモック
- リポジトリテスト:
  - `@DataJpaTest` + Testcontainers Postgres (in-memory H2 は禁止、本番 DB と差が出るため)
- 結合テスト:
  - `@SpringBootTest(webEnvironment = RANDOM_PORT)` + TestRestTemplate / WebTestClient
  - Testcontainers Postgres を `@Container static` で 1 つ起動 (Singleton パターン)
- E2E:
  - 別 module または `src/e2eTest/java` に Testcontainers + RestAssured
- 命名:
  - クラス: `<対象>Test`
  - メソッド: `should_<期待結果>_when_<条件>` または日本語 `@DisplayName`
- データ生成:
  - 静的 factory メソッド (`UserTestFixture.aValidUser()`) または ObjectMother パターン
  - テストデータは `@Sql` ではなく fixture コードで構築する
- フィクスチャ DB クリーンアップ:
  - `@Transactional` (自動ロールバック) または `@Sql(executionPhase = AFTER_TEST_METHOD)` で truncate

## OVERRIDE
- 「Red 確認」→ `./gradlew test --fail-fast` で 1 件目失敗時に停止し、結果を Red 確認ログに貼付

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `src/test/java/.../testfixture/<対象>TestFixture.java`
- `src/test/resources/application-test.yml` (Testcontainers JDBC URL を datasource に注入)
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- 単体テストで Spring コンテキスト起動を不要に使っていないか (速度低下)
- `@DataJpaTest` で in-memory DB を使っていないか (Testcontainers Postgres を使う)
- `@MockBean` を多用しすぎていないか (再起動コスト高)
- AssertJ のチェイン構造で読みやすく書かれているか
- テストメソッド名 / `@DisplayName` でシナリオが読み取れるか
- Red 確認時に compile error / `@Autowired` 解決失敗が混ざっていないか
