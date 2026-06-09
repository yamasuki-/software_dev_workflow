# integration-test-review — react-native rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の react-native 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行

### 実 DB / 外部システム
- [ ] ネイティブ依存はモック (Camera / Notification 等)、API は msw + 実 backend (sandbox)
- [ ] expo-secure-store / AsyncStorage の状態遷移結合テスト

### 結合固有
- [ ] ネイティブモジュール ↔ JS ブリッジの結合
- [ ] 画面遷移 (Expo Router) と状態管理の連動
- [ ] permission 要求フローの結合テスト

### 安定性
- [ ] ネイティブモック汚染なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
