# integration-test-review — python-django rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の python-django 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行

### 実 DB / 外部システム
- [ ] 本物の Postgres を使用
- [ ] Redis / Celery worker も実物
- [ ] マイグレーション実行後に結合テスト

### 結合固有
- [ ] N+1 を `django-debug-toolbar` / `silk` で検出
- [ ] app をまたぐシナリオが含まれる
- [ ] admin 画面の smoke test (運用ツールとして使う場合)
- [ ] Celery タスクをテストする場合、eager と worker 両方を検討

### 安定性
- [ ] testcontainers 起動安定
- [ ] transaction=True と False の使い分けが正しい

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
