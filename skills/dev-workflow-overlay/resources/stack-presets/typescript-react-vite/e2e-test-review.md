# e2e-test-review — typescript-react-vite rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の typescript-react-vite 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / ユースケース / USDM `R-###` を Playwright でカバー (100% 必須)

### E2E 固有
- [ ] Playwright で chromium 必須
- [ ] Trace / video 取得設定
- [ ] HTML レポート保存
- [ ] a11y を @axe-core/playwright で検証

### 安定性
- [ ] flaky なし / 並列実行で安定
- [ ] Lighthouse / Web Vitals 計測 (NFR にあれば)

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"
- [ ] Playwright trace 添付

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
