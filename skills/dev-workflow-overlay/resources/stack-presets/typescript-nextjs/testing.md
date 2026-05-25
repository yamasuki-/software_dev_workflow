# testing — TypeScript + Next.js rules

## ADD
- カバレッジ: Vitest なら `--coverage` (v8 provider)、Jest なら built-in
  - スタック既定目標: 行 80% / 分岐 75%
  - UI コンポーネントは project 層で目標を緩めるのを許容
- E2E: Playwright
  - CI で chromium 必須、project に応じて firefox / webkit / mobile を追加
  - `--reporter=html` で `playwright-report/` を生成しアーティファクト化
  - Trace (`--trace=on-first-retry`) を有効化し失敗時の調査性確保
- 視覚回帰 (必要時): Playwright snapshot または Chromatic (project 層判断)
- 実行方法:
  - `pnpm test` → Vitest/Jest (watch なし)
  - `pnpm test:e2e` → Playwright
  - `pnpm coverage` → カバレッジ生成
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す
  - Vitest/Jest の `--reporter=junit` + Playwright の HTML レポートを添付

## OVERRIDE
- 「テスト未実施 / 実施不可は理由」→ Vitest/Jest の `.skip` / Playwright の `test.skip(condition, reason)` の reason を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/junit.xml`
- `docs/04_test_results/<FID>/coverage.html`
- `docs/04_test_results/<FID>/playwright-report/` (Playwright の HTML レポート)

## REVIEW_EXTRAS
- カバレッジが目標を満たしているか (UI 緩和は project 層で明文化されているか)
- Playwright のトレースが失敗時に取得できる設定か
- skip テストに reason があるか
- E2E が parallel 実行で fail しないか
- 視覚回帰が必要なら設定されているか
- Lighthouse / Web Vitals 計測が basic-design の NFR にある場合、CI に組み込まれているか
