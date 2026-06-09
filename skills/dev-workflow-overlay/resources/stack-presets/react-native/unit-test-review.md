# unit-test-review — react-native rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の react-native 固有レビュー観点。

### 実施網羅性
- [ ] Jest (jest-expo preset) で全単体ケース実行
- [ ] skip に reason

### カバレッジ (単体)
- [ ] 行 75% / 分岐 65% 以上 (UI が重く控えめ)
- [ ] coverage.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] @testing-library/react-native + jest-native matcher 活用
- [ ] testID 濫用なし (label / role 優先)
- [ ] ネイティブモジュールの mock が test 間で汚染しない
- [ ] TanStack Query test client isolated

### 安定性
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
