# testing-review — Java + Spring Boot rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが JUnit で実行
- [ ] `@Disabled` に reason
- [ ] CI が緑

### カバレッジ
- [ ] 行 85% / 分岐 75% (スタック既定)
- [ ] JaCoCo HTML / XML が `docs/04_test_results/<FID>/` にある
- [ ] 生成コード (record / config / mapper 生成物) が exclude されている
- [ ] Service / Controller / Repository / Domain にカバレッジが分散

### 結合 / E2E
- [ ] Testcontainers Postgres で実行 (H2 を使っていない)
- [ ] Testcontainers コンテナを singleton で起動しテスト時間が肥大していないか
- [ ] 1 シナリオあたりのクエリ数を測定し N+1 を検知しているか
- [ ] E2E が basic-design のユースケースを網羅

### Spring 固有の落とし穴
- [ ] `@MockBean` の使用がコンテキスト再起動を多発させていないか
- [ ] `@DirtiesContext` の使用が必要最小限か
- [ ] `application-test.yml` で外部依存が test 用に上書きされているか

### セキュリティテスト
- [ ] 認証 / 認可境界 (200 / 401 / 403) のテストがある
- [ ] CSRF / CORS の挙動テストがある (該当時)

### 不具合
- [ ] 不具合票が作成されている
- [ ] failing test の `build/reports/tests/test/` 抜粋が添付

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] Testcontainers のコンテナ共有でテスト時間が許容内か
- [ ] テストフィクスチャ / ObjectMother が機能間で重複していないか
- [ ] CI 全体の Gradle build time が許容範囲か
