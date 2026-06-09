# integration-test-review — python-fastapi rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の python-fastapi 固有レビュー観点。

### 実施網羅性
- [ ] テスト設計の結合ケース (IT-NNN) すべてに対応する pytest 実行結果がある

### 実 DB / 外部システム
- [ ] 本物の Postgres を使用 (in-memory SQLite で済ませていない)
- [ ] テスト DB のバージョンが本番と一致
- [ ] Redis 等の外部システムも実物 (docker compose で起動)

### 結合固有
- [ ] N+1 クエリの検出テストがある (`selectinload` / `joinedload` 適用箇所)
- [ ] トランザクション境界 (rollback / savepoint) のテストがある
- [ ] 機能間連携のシナリオ (基本設計の機能間依存) が検証されている
- [ ] FastAPI の Lifespan / Dependency Override が適切に使われている

### 安定性
- [ ] testcontainers 起動が安定 (タイムアウトせず)
- [ ] テストデータの後始末が transactional rollback / truncate で確実

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
