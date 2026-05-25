# testing-review — TypeScript + React + Vite rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが Vitest/Jest / Playwright で実行されている
- [ ] skip テストに reason がある
- [ ] CI が緑

### カバレッジ
- [ ] 行 80% / 分岐 70% (スタック既定、UI 緩和は project 層で明文化)
- [ ] coverage.html が `docs/04_test_results/<FID>/` にある
- [ ] features / components / hooks / lib それぞれにカバレッジが分散

### コンポーネントテスト
- [ ] @testing-library 中心 (`getByRole` / `userEvent`)
- [ ] act() 警告なし
- [ ] msw でリアルな API レスポンスをモック (固定 mock の濫用なし)
- [ ] TanStack Query の test client が isolated

### E2E
- [ ] 主要ユーザフロー (basic-design ユースケース) を網羅
- [ ] Trace / video が失敗時に取得される
- [ ] parallel 実行で fail しない
- [ ] CI で chromium 最低必須

### アクセシビリティ
- [ ] jest-axe または @axe-core/playwright で違反 0

### パフォーマンス / 監視
- [ ] Web Vitals 計測が NFR にあれば実施
- [ ] バンドルサイズ diff が CI で監視されている

### 不具合
- [ ] 不具合票が作成されている
- [ ] failing test の出力 / Playwright trace が添付

### 横断 (cross) モード追加観点
- [ ] features 間でカバレッジに極端な偏りがないか
- [ ] msw ハンドラが共通化されているか
- [ ] Playwright fixture / helper が共通化されているか
- [ ] CI 全体の実行時間が許容範囲か
