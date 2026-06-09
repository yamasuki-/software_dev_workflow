# unit-test-review — go-stdlib-chi rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の go-stdlib-chi 固有レビュー観点。

### 実施網羅性
- [ ] 全単体ケースが go test で実行 (`-race` 込み)
- [ ] t.Skip に reason

### カバレッジ (単体)
- [ ] 行カバレッジ 80% 以上 (Go は分岐網羅標準なし)
- [ ] cover.out / cover.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] テーブル駆動テストが活用されている
- [ ] testify/require と assert の使い分けが適切
- [ ] 関数命名 `Test<対象>_<シナリオ>_<期待結果>`
- [ ] インタフェースの mock が公開 API シグネチャと一致

### 安定性
- [ ] `go test -race` が pass
- [ ] goroutine リーク無し (goleak 推奨)

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
