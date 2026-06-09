# unit-test-review — python-fastapi rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の python-fastapi 固有レビュー観点。

### 実施網羅性
- [ ] テスト設計の単体ケース (UT-NNN) すべてに対応する pytest 実行結果がある
- [ ] skip / xfail には reason が記載されている

### カバレッジ (単体)
- [ ] 行カバレッジ 85% 以上 (スタック既定、project 層で上書き可)
- [ ] 分岐カバレッジ 80% 以上
- [ ] coverage.html が docs/04_test_results/<FID>/ にある

### 単体テスト固有
- [ ] モック対象が外部依存のみ (内部ロジックを過剰にモックしていない)
- [ ] pytest-mock の `mocker.patch` の対象がモジュール境界を跨ぐもののみ
- [ ] 関数命名が `test_<対象>_<シナリオ>_<期待結果>` 規約
- [ ] AAA パターン (Arrange/Act/Assert) で書かれている

### 安定性
- [ ] flaky なテストがない
- [ ] pytest -n auto の並列実行で fail しない

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
