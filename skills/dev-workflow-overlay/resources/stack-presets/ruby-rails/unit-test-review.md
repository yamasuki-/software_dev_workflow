# unit-test-review — ruby-rails rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の ruby-rails 固有レビュー観点。

### 実施網羅性
- [ ] RSpec で全単体ケース実行
- [ ] skip / pending に reason

### カバレッジ (単体)
- [ ] 行 85% / 分岐 75% 以上
- [ ] SimpleCov coverage/index.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] request spec を使い controller spec を新規追加していない
- [ ] FactoryBot traits 活用、データ生成が読みやすい
- [ ] 共通 helper が spec/support/ に整理
- [ ] AAA パターン

### 安定性
- [ ] flaky なし
- [ ] slow test 上位 10 件が許容内 (`--profile=10`)

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
