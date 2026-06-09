# integration-test-review — typescript-nextjs rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の typescript-nextjs 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行 (server action / API route)

### 実 DB / 外部システム
- [ ] 本物の Postgres を使用 (Prisma / Drizzle 経由)
- [ ] testcontainers などで起動

### 結合固有
- [ ] server action / API ルートの結合テスト
- [ ] cache 戦略 (force-cache / revalidate) の検証
- [ ] middleware + server action の認可二重チェックが結合層でテスト

### 安定性
- [ ] cookie / session の後始末が確実

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
