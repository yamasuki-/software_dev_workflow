# e2e-test-review — python-django rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の python-django 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / USDM `R-###` を E2E カバー (100% 必須)

### E2E 固有
- [ ] DRF APIClient で実 HTTP / 本物の Postgres 使用
- [ ] 業務シナリオ (複数 app またぎ) が含まれる
- [ ] 認証フロー (login/logout/permission) が含まれる

### 安定性
- [ ] flaky なし
- [ ] 実行環境が明記

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"
- [ ] 重大度 / 影響範囲記載

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
