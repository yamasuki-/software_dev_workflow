# unit-test-review — typescript-nextjs rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の typescript-nextjs 固有レビュー観点。

### 実施網羅性
- [ ] Vitest / Jest で全単体ケース実行
- [ ] skip に reason

### カバレッジ (単体)
- [ ] 行 80% / 分岐 75% 以上
- [ ] UI コンポーネントは project 層で目標緩和許容
- [ ] coverage.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] @testing-library/react の `getByRole` / `userEvent` 中心
- [ ] act() 警告なし
- [ ] msw でリアルな API レスポンスをモック
- [ ] TanStack Query の test client が isolated

### 安定性
- [ ] flaky なし
- [ ] parallel 実行で fail しない

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
