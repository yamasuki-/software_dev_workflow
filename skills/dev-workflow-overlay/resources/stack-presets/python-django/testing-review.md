# testing-review — Python + Django rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが pytest で実行されている
- [ ] skip / xfail に reason がある
- [ ] CI が緑

### カバレッジ
- [ ] 行 85% / 分岐 80% 以上 (スタック既定)
- [ ] カバレッジレポート (HTML or XML) が `docs/04_test_results/<FID>/` に保存されている
- [ ] models / services / views / serializers それぞれにカバレッジが分散しているか

### マイグレーション
- [ ] マイグレーション未生成 (`makemigrations --check`) で 0 件
- [ ] データ移行 migration には専用テストがある
- [ ] migration を逆方向にも安全に流せるか確認している (downgrade テスト or 検討記録)

### 結合 / E2E
- [ ] 結合・E2E は本物の Postgres / Redis に対して実行
- [ ] Celery タスクをテストする場合、eager mode と worker 実行両方を検討
- [ ] admin 画面の smoke test が必要なら含まれているか

### 安定性
- [ ] flaky テストがないか (シグナル / async / Celery 経路で発生しやすい)
- [ ] テスト DB の seed / teardown が他テストに残らないか
- [ ] テスト全体の実行時間が許容内か

### 不具合
- [ ] 不具合票が作成されているか
- [ ] failing test の出力が貼付されているか

### 横断 (cross) モード追加観点
- [ ] app 間でカバレッジが極端に偏っていないか
- [ ] 結合テストで app をまたぐシナリオが含まれているか
- [ ] CI 全体の実行時間が許容範囲か
- [ ] django-debug-toolbar / silk で計測した N+1 数の推移
