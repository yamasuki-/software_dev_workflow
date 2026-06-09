# e2e-test-review — react-native rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の react-native 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / ユースケース を Maestro/Detox でカバー (100% 必須)

### E2E 固有
- [ ] Maestro 推奨 (YAML) または Detox
- [ ] iOS / Android 双方で実行 (要件で片方限定の場合は明文化)
- [ ] エミュレータ / シミュレータ環境が CI で再現可能
- [ ] 手動テストマトリクス (主要機種・OS) が記録

### 安定性
- [ ] 実機での起動時間 / メモリ使用が NFR を満たす
- [ ] crash 率 / ANR が許容内

### 配布
- [ ] EAS Build (preview profile) が成功
- [ ] EAS Submit で社内配布可能

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"
- [ ] Maestro/Detox trace 添付

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
