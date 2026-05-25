# testing — Java + Spring Boot rules

## ADD
- カバレッジ: JaCoCo (`jacocoTestReport` + `jacocoTestCoverageVerification`)
  - スタック既定目標: 行 85% / 分岐 75%
  - `excludes` で生成コード / config を除外
- 結合 / E2E は Testcontainers Postgres (本物の PostgreSQL バージョン固定)
  - H2 / HSQLDB は使わない (本番との差で false green が出る)
- ログ検証:
  - 必要なら `OutputCaptureExtension` (`@ExtendWith`) で stdout を assert
- パフォーマンス:
  - JMH を必要時 (内部ループのマイクロベンチ)
- 実行方法:
  - `./gradlew test` → 単体 + 結合
  - `./gradlew e2eTest` → E2E (別 source set)
  - `./gradlew jacocoTestReport` → カバレッジ HTML
- 結果は `docs/04_test_results/<FID>/` に Markdown で残す
  - `build/reports/tests/test/index.html` のサマリと `jacoco/test/html/index.html` を添付参照
  - JUnit XML (`build/test-results/test/`) を CI で集計

## OVERRIDE
- 「テスト未実施 / 実施不可は理由」→ JUnit の `@Disabled("reason")` の reason を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/jacoco.html` または XML
- `docs/04_test_results/<FID>/junit.xml`

## REVIEW_EXTRAS
- カバレッジが目標を満たすか (生成コード除外設定が正しいか)
- 結合・E2E が Testcontainers Postgres で実行されているか
- 結合テスト 1 シナリオあたりの実行クエリ数を測定し N+1 を検知しているか (`@AutoConfigureTestEntityManager` + `Statistics` 等)
- flaky テスト (Testcontainers 起動タイミング / ポート衝突) が出ていないか
- `@Disabled` に reason
- Actuator endpoints のセキュリティが production profile で締まっているか
