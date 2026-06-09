# e2e-test-review — python-fastapi rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の python-fastapi 固有レビュー観点。

### 要件カバレッジ
- [ ] 要件定義書の全ユースケース / USDM `R-###` が E2E でカバー (100% 必須)
- [ ] 受入条件 (Given-When-Then) が E2E の期待結果に転記

### E2E 固有
- [ ] httpx.AsyncClient で実 HTTP 通信を実施 (TestClient ではなく)
- [ ] 別 compose スタックで本物の Postgres / Redis に対して実行
- [ ] 業務シナリオ (複数機能をまたぐ) が含まれる

### 安定性
- [ ] flaky シナリオがない
- [ ] 実行環境 (本番に近い) が結果ドキュメントに明記

### 不具合
- [ ] 不具合票が `docs/05_bug_reports/B<番号>.md` に作成、`found_in_test_layer = "e2e"`
- [ ] 重大度 / 影響範囲が記載

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
