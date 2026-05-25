# testing-review — React Native rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが Jest / E2E (Maestro/Detox) で実行されている
- [ ] skip テストに reason がある
- [ ] CI が緑

### カバレッジ
- [ ] 行 75% / 分岐 65% (スタック既定)
- [ ] coverage.html が `docs/04_test_results/<FID>/` にある
- [ ] features / components / hooks にカバレッジが分散

### コンポーネント / 単体
- [ ] @testing-library/react-native の matcher (jest-native) が活用されている
- [ ] testID 濫用なし (label / role 優先)
- [ ] ネイティブモジュールの mock が test 間で汚染していない

### E2E
- [ ] 主要ユーザフロー (basic-design ユースケース) を Maestro / Detox で網羅
- [ ] iOS / Android 双方で実行 (project 要件で片方限定の場合は明文化)
- [ ] エミュレータ / シミュレータ環境が CI で再現可能

### 手動テストマトリクス
- [ ] 主要機種・OS バージョン組合せでの実機確認結果が記録されている
- [ ] 主要画面サイズで UI が崩れていないか
- [ ] アクセシビリティ (VoiceOver / TalkBack) を主要画面で確認

### パフォーマンス・安定性
- [ ] 起動時間 / メモリ使用が NFR を満たす
- [ ] 60fps を求める箇所のフレーム率を計測
- [ ] crash 率 / ANR が許容内 (本番計測との連携)

### 配布
- [ ] EAS Build (`preview` profile) が成功
- [ ] EAS Submit を経て社内配布できる状態
- [ ] OTA (EAS Update) で配布可能な範囲かを明示

### 不具合
- [ ] 不具合票が作成されている
- [ ] failing test の出力 / Maestro/Detox の trace が添付

### 横断 (cross) モード追加観点
- [ ] features 間でカバレッジに極端な偏りがないか
- [ ] msw ハンドラ / テストヘルパが共通化されているか
- [ ] E2E の helper / page object が共通化されているか
- [ ] CI 全体の実行時間が許容範囲か
