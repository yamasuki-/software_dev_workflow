# test-implementation — React Native rules

## ADD
- 単体・コンポーネント:
  - **Jest** (`jest-expo` preset)
  - @testing-library/react-native + @testing-library/jest-native (matchers)
- API モック:
  - msw を Node mode で使用 (`tests/msw/handlers.ts`)
- TanStack Query テスト:
  - 各テストで `QueryClient` を new、retry を 0 に
  - `<QueryClientProvider client={testClient}>` でラップ
- ネイティブモジュールのモック:
  - `jest.mock('expo-camera', ...)` などで明示モック
  - `jest-expo` preset が用意するモックを優先
- E2E:
  - **Maestro** を推奨 (YAML スクリプト、CI 統合容易)
  - 必要に応じて Detox (Bare workflow / 詳細制御が必要な時)
  - 実機 / シミュレータでの実行をどこまで CI 化するか project 層で判断
- 命名:
  - 単体: `<対象>.test.ts(x)` 同ディレクトリ
  - E2E (Maestro): `e2e/maestro/<flow>.yaml`
  - E2E (Detox): `e2e/detox/<flow>.test.ts`

## OVERRIDE
- 「Red 確認」→ Jest `--bail` で 1 件目失敗時に停止し、出力を Red 確認ログに貼付。E2E 未実装の段階では単体のみで Red 確認

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `tests/msw/handlers.ts`
- `tests/setup.ts` (Jest setup、msw 起動、matcher 登録)
- `tests/test-utils.tsx` (`renderWithProviders` ヘルパ)
- `e2e/maestro/` または `e2e/detox/`
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- @testing-library/react-native の `getByRole` / `getByLabelText` 中心で書かれているか (testID 濫用回避)
- async (`findBy...` / `waitFor`) が適切に使われているか
- ネイティブモジュールのモックが test 間で混線していないか
- TanStack Query test client が isolated か
- E2E の選定 (Maestro / Detox) 理由が `project-config.md` に記録されているか
- Red 確認時に native module の動的解決エラーが混ざっていないか
