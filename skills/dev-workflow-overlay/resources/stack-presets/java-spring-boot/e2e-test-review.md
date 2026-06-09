# e2e-test-review — java-spring-boot rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の java-spring-boot 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / USDM `R-###` を E2E カバー (100% 必須)

### E2E 固有
- [ ] RestAssured + Testcontainers で別プロセス E2E
- [ ] 認証 / 認可境界 (200 / 401 / 403) のテスト
- [ ] CSRF / CORS の挙動テスト (該当時)
- [ ] 業務シナリオ含む

### 安定性
- [ ] Testcontainers 共有でテスト時間が許容内
- [ ] flaky なし

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"
- [ ] build/reports/tests/test/ 抜粋添付

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
