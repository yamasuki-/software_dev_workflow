# testing — React Native rules

## ADD
- カバレッジ: Jest built-in (`--coverage`)
  - スタック既定目標: 行 75% / 分岐 65%
- E2E:
  - Maestro: ローカル + CI で headless 実行 (Android エミュレータ / iOS シミュレータ)
  - Detox: Bare workflow で必要時
- 手動テストマトリクス:
  - 主要機種・OS 組合せ (project 層で具体化、例: iOS 17/18 + Android 13/14)
  - 主要画面サイズ (small phone / regular / tablet)
- 配布前テスト:
  - EAS Build の `preview` profile で実機配布 → 受け入れテスト
  - 受け入れ完了後 `production` build → ストア提出
- パフォーマンス:
  - 60fps を目標とする箇所は Flipper / Hermes プロファイラで計測
  - 起動時間 / メモリ消費の規定値を NFR で定義
- 実行方法:
  - `pnpm test` → Jest
  - `pnpm test:e2e` → Maestro / Detox
  - `pnpm coverage` → カバレッジ生成

## OVERRIDE
- 「テスト未実施 / 実施不可は理由」→ Jest `.skip` の reason、Maestro の skip コマンド理由を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/coverage.html`
- `docs/04_test_results/<FID>/junit.xml`
- `docs/04_test_results/<FID>/manual-test-matrix.md` (機種・OS マトリクス結果)
- `docs/04_test_results/<FID>/maestro-results/` または `detox-artifacts/`

## REVIEW_EXTRAS
- カバレッジが目標 (行 75%) を満たしているか
- E2E が主要ユーザフローを網羅
- 手動テストマトリクスが必要機種・OS をカバーしているか
- 実機での起動時間 / メモリ使用が NFR を満たすか
- skip テストに reason
- crash 率 / ANR が新規追加機能で増えていないか (本番監視と CI の関係を明示)
