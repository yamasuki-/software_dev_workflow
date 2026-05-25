# testing-review — Python + FastAPI rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースに対応する pytest 実行結果がある
- [ ] skip / xfail には reason が記載されている
- [ ] CI が緑になっている

### カバレッジ
- [ ] 行カバレッジ 85% 以上 (スタック既定、project 層で上書き可)
- [ ] 分岐カバレッジ 80% 以上
- [ ] カバレッジレポート (HTML or XML) が `docs/04_test_results/<FID>/` に保存されている

### 結合 / E2E
- [ ] 結合・E2E は本物の Postgres / Redis に対して実行されている (in-memory モックで済ませていない)
- [ ] テスト DB が本番と同じ Postgres バージョンか
- [ ] E2E のシナリオが basic-design のユースケースを網羅しているか

### 安定性
- [ ] flaky テスト (再実行で結果が変わる) がないか
- [ ] テスト並列実行 (`pytest -n auto`) で fail しないか
- [ ] テスト全体の実行時間が project 規定内か

### 不具合
- [ ] 不具合票が `docs/05_bug_reports/B<番号>.md` に作成されているか
- [ ] 各不具合に対応する failing test の出力が貼付されているか
- [ ] 重大度 / 影響範囲が記載されているか

### 横断 (cross) モード追加観点
- [ ] 機能ごとのカバレッジに極端な偏りがないか (一部機能だけ 50% 未満など)
- [ ] 共通モジュール (`core/`, `schemas/common/`) のテストが個別機能テスト内に重複していないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] CI 全体の実行時間が許容範囲内か
