# test-implementation — TypeScript + Next.js rules

## ADD
- 単体・コンポーネント:
  - テストランナーは Vitest または Jest (project 層で 1 つ選定)
  - DOM 環境: jsdom または happy-dom
  - @testing-library/react + @testing-library/user-event を使用
- Server Component / server actions:
  - 純粋関数は Vitest/Jest で直接呼んで検証
  - 副作用がある action は msw + fetch / DB をモックして検証
- API ルート:
  - handler を import して `NextRequest` を渡し直接呼ぶ
  - もしくは Playwright で実 HTTP
- E2E:
  - Playwright (`playwright.config.ts`)
  - 主要ブラウザ (chromium / firefox / webkit) を CI で最低 chromium 必須
  - `npx playwright test --ui` でローカルデバッグ
- fetch モック:
  - msw を server / browser 両方で利用 (Setup を `tests/msw/` に集約)
- DB を伴うテスト:
  - 単体: 抽象 (repository interface) をモック
  - 結合: testcontainers (Postgres) を起動して Prisma / Drizzle client で接続
- 命名:
  - 単体: `<対象>.test.ts(x)` (同ディレクトリまたは `__tests__/`)
  - E2E: `tests/e2e/<シナリオ>.spec.ts`
- E2E は **データセットアップを test 内で完結** (前テストの状態に依存しない)

## OVERRIDE
- 「Red 確認」→ Vitest/Jest なら `--bail` で 1 件目失敗で停止、Playwright なら `--reporter=list --max-failures=1`。失敗内容を Red 確認ログに貼付

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `tests/msw/handlers.ts` (msw のハンドラ集約)
- `tests/setup.ts` (Vitest/Jest 共通セットアップ)
- `playwright.config.ts`
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- @testing-library を使い、`screen.getByRole` / `userEvent` 中心で書かれているか (DOM 構造に依存しすぎていないか)
- act() の警告が出ていないか
- async コンポーネントのテストで `await screen.findBy...` を使っているか
- msw ハンドラが test 終了時に reset されているか
- E2E が他テストの状態に依存していないか (parallel 実行で fail しないか)
- Red 確認時に compile error が混ざっていないか
