# integration-test-review — java-spring-boot rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の java-spring-boot 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行

### 実 DB / 外部システム
- [ ] Testcontainers Postgres を使用 (H2 不可)
- [ ] Testcontainers のコンテナ singleton 起動でテスト時間制御

### 結合固有
- [ ] @DataJpaTest + Testcontainers / @SpringBootTest RANDOM_PORT
- [ ] TestRestTemplate / WebTestClient で実 HTTP
- [ ] 1 シナリオあたりクエリ数を測定し N+1 検知
- [ ] application-test.yml で外部依存上書き

### 安定性
- [ ] @DirtiesContext 使用が最小限
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
