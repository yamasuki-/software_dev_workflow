# e2e-test-review — go-stdlib-chi rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の go-stdlib-chi 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / USDM `R-###` を E2E カバー (100% 必須)

### E2E 固有
- [ ] httptest.NewServer or 別プロセスで実 HTTP
- [ ] RestAssured 相当 / cURL / Go client で E2E
- [ ] 業務シナリオ含む

### 安定性
- [ ] 実行環境明記
- [ ] downgrade 戦略の検証 (逆向き migration テストがあれば)

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
