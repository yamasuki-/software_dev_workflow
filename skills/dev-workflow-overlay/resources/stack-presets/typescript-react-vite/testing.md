# testing — TypeScript + React + Vite rules

## ADD
- カバレッジ: Vitest なら `--coverage` (v8)、Jest なら built-in
  - スタック既定目標: 行 80% / 分岐 70% (UI は project 層で緩和許容)
- E2E: Playwright
  - CI で chromium 必須、要件に応じて mobile / firefox / webkit を追加
  - Trace (`--trace=on-first-retry`) / video を失敗時に有効化
  - HTML レポートを `playwright-report/` に出力しアーティファクト化
- アクセシビリティ:
  - 単体テストで jest-axe を主要画面に
  - E2E で `@axe-core/playwright` を主要 page に
- 視覚回帰 (必要時): Chromatic または Playwright snapshot (project 層で判断)
- 実行方法:
  - `pnpm test` → Vitest/Jest
  - `pnpm test:e2e` → Playwright
  - `pnpm coverage` → カバレッジ生成
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す

## OVERRIDE
- 「テスト未実施 / 実施不可は理由」→ Vitest/Jest `.skip` / Playwright `test.skip(condition, reason)` の reason を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/junit.xml`
- `docs/04_test_results/<FID>/coverage.html`
- `docs/04_test_results/<FID>/playwright-report/`

## REVIEW_EXTRAS
- カバレッジが目標を満たしているか
- E2E の主要フローが basic-design のユースケースを網羅
- a11y 違反 (jest-axe / @axe-core/playwright) が 0 件
- Playwright のトレースが失敗時に取得できる設定
- Lighthouse / Web Vitals 計測が NFR にあれば実施されているか
- skip テストに reason
