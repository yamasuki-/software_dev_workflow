# integration-test-review — typescript-react-vite rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の typescript-react-vite 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行

### 実 DB / 外部システム
- [ ] SPA なので backend は別リポジトリ。msw + 実 backend (sandbox) の hybrid
- [ ] API レスポンスの本物との一致を確認

### 結合固有
- [ ] 複数 feature 連携 (例: 認証 → データ取得 → 表示) のシナリオ
- [ ] TanStack Query キャッシュ無効化の連動
- [ ] React Router のナビゲーション結合

### 安定性
- [ ] msw ハンドラの reset が確実

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
