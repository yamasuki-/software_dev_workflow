# unit-test-review — java-spring-boot rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の java-spring-boot 固有レビュー観点。

### 実施網羅性
- [ ] JUnit 5 で全単体ケース実行
- [ ] @Disabled に reason

### カバレッジ (単体)
- [ ] 行 85% / 分岐 75% 以上
- [ ] JaCoCo HTML / XML が docs/04_test_results/<FID>/ にある
- [ ] 生成コード (record / mapper) は exclude

### 単体テスト固有
- [ ] Spring コンテキスト起動を不要に使っていない (速度低下回避)
- [ ] AssertJ チェイン構造で読みやすい
- [ ] テストメソッド名 / @DisplayName でシナリオ読み取り可能
- [ ] Mockito の @MockBean 多用しすぎていない

### 安定性
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
