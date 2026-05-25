# test-implementation — TypeScript + React + Vite rules

## ADD
- 単体・コンポーネント:
  - Vitest または Jest (project 層で 1 つ選定、Vitest 推奨)
  - DOM 環境: jsdom または happy-dom
  - @testing-library/react + @testing-library/user-event
- API モック:
  - msw (Mock Service Worker) を `tests/msw/handlers.ts` に集約
  - test 開始時 `server.listen()`、終了時 `server.close()`、各 test 終了時 `server.resetHandlers()`
- TanStack Query テスト:
  - 各テストで `QueryClient` を new し、デフォルトの retry を 0 にする (タイムアウト短縮)
  - `<QueryClientProvider client={testClient}>` でラップ
- E2E: Playwright (CI で chromium 必須)
- 命名:
  - 単体: `<対象>.test.ts(x)` (同ディレクトリ) または `__tests__/<対象>.test.ts(x)`
  - E2E: `tests/e2e/<シナリオ>.spec.ts`
- アクセシビリティテスト: `jest-axe` または `vitest-axe` を主要画面に適用
- Storybook を使う場合は `*.stories.tsx` 経由のテスト (test-runner) を併用可

## OVERRIDE
- 「Red 確認」→ Vitest/Jest `--bail` または `--run` で 1 件目失敗時に停止し、出力を Red 確認ログに貼付

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `tests/msw/handlers.ts` (msw ハンドラ)
- `tests/setup.ts` (Vitest/Jest 共通セットアップ、msw 起動、jest-axe matcher 登録)
- `tests/test-utils.tsx` (`renderWithProviders` ヘルパ: QueryClient / Router / Theme)
- `playwright.config.ts`
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- @testing-library の `screen.getByRole` / `userEvent` 中心で書かれているか (DOM 詳細に依存しすぎていないか)
- act() 警告が出ていないか
- async 取得には `await screen.findBy...` / `waitFor` を使っているか
- msw ハンドラが各テスト終了で reset されているか
- TanStack Query の test client が isolated か (テスト間でキャッシュ共有していないか)
- jest-axe で主要画面の a11y 違反が 0 か
- Red 確認時の失敗理由が「未実装」「props 型ミス」など想定通りか
