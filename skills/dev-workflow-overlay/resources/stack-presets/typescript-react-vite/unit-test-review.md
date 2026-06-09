# unit-test-review — typescript-react-vite rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の typescript-react-vite 固有レビュー観点。

### 実施網羅性
- [ ] Vitest / Jest で全単体ケース実行
- [ ] skip に reason

### カバレッジ (単体)
- [ ] 行 80% / 分岐 70% 以上
- [ ] UI 緩和は project 層で明文化
- [ ] coverage.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] @testing-library/react 中心 (getByRole / userEvent)
- [ ] act() 警告なし
- [ ] msw でモック / 各テスト終了で reset
- [ ] TanStack Query の test client が isolated
- [ ] jest-axe で a11y 違反 0

### 安定性
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
