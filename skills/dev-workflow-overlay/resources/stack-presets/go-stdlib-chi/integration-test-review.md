# integration-test-review — go-stdlib-chi rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の go-stdlib-chi 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース全実行

### 実 DB / 外部システム
- [ ] testcontainers-go で本物の Postgres
- [ ] sqlmock 等で済ませていない
- [ ] docker compose で外部システムも実物

### 結合固有
- [ ] sqlc 生成物が結合テストで動作確認
- [ ] migration → アプリ起動 → リクエスト処理 まで通っている
- [ ] N+1 検出
- [ ] context キャンセル / タイムアウト挙動

### 安定性
- [ ] testcontainers コンテナの suite 共有でテスト時間が許容内
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
