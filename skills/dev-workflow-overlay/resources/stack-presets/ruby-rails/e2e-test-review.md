# e2e-test-review — ruby-rails rules

## REVIEW_EXTRAS

> 検証対象 = **要件定義書 (USDM `R-###` / ユースケース)**。E2E テスト層の ruby-rails 固有レビュー観点。

### 要件カバレッジ
- [ ] 全要件 / ユースケース を system spec でカバー (100% 必須)

### E2E 固有
- [ ] system spec (Capybara + Cuprite) で headless
- [ ] 主要 flow を network 込みで通す
- [ ] Turbo Stream / Frame の動作確認
- [ ] スクリーンショット (失敗時) が CI で取得

### 安定性
- [ ] Cuprite headless で安定
- [ ] flaky なし

### 不具合
- [ ] 不具合票作成 + found_in_test_layer="e2e"
- [ ] failing spec の出力 (`bundle exec rspec --format doc`) 添付

### 横断 (cross) モード追加観点
- [ ] 全機能横断で要件カバレッジが 100% 達成 (1 要件 = 0 E2E が無い)
- [ ] 業務シナリオ (複数機能またぎ) が含まれる
- [ ] E2E helper / page object が機能間で共通化されているか
- [ ] CI 全体の E2E 実行時間が許容範囲内か
- [ ] crash 率 / ANR 等 (該当時) が新規追加機能で増えていないか
