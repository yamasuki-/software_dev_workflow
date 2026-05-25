# testing-review — TypeScript + Next.js rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが Vitest/Jest / Playwright で実行されている
- [ ] skip テストに reason がある
- [ ] CI が緑

### カバレッジ
- [ ] 行 80% / 分岐 75% (スタック既定、UI 緩和は project 層で明文化)
- [ ] coverage.html が `docs/04_test_results/<FID>/` にある
- [ ] features / components / server / lib それぞれにカバレッジが分散

### E2E (Playwright)
- [ ] 主要ユーザフロー (basic-design ユースケース) が網羅
- [ ] Trace / video が失敗時に取得できる設定
- [ ] parallel 実行で fail しない (test isolation)
- [ ] CI で chromium 最低必須、project 要件に応じて firefox / webkit / mobile

### サーバ側
- [ ] server action / API ルートのテストが含まれている
- [ ] zod スキーマの境界ケース (invalid input) がテストされている
- [ ] 認可失敗 (未認証 / 権限不足) のテストがある

### パフォーマンス / 監視
- [ ] Lighthouse / Web Vitals 計測が NFR にあれば実施されているか
- [ ] バンドルサイズの diff が CI で監視されているか (size-limit / bundle-analyzer)

### 不具合
- [ ] 不具合票が作成されている
- [ ] failing test の出力 (Vitest/Jest の error / Playwright trace) が添付されている

### 横断 (cross) モード追加観点
- [ ] features 間でテストカバレッジに極端な偏りがないか
- [ ] msw ハンドラが共通化されているか (重複定義していないか)
- [ ] Playwright の helper / fixture が共通化されているか
- [ ] CI 全体の実行時間が許容範囲か
