# integration-test-review — ruby-rails rules

## REVIEW_EXTRAS

> 検証対象 = **基本設計**。INTEGRATION テスト層の ruby-rails 固有レビュー観点。

### 実施網羅性
- [ ] 結合ケース (request spec) 全実行

### 実 DB / 外部システム
- [ ] 本物の Postgres 使用
- [ ] WebMock + VCR で外部 HTTP モック (cassette に機密含めない)
- [ ] VCR cassette 再録タイミング明示

### 結合固有
- [ ] N+1 を bullet で検知 0 件
- [ ] ApplicationController の rescue_from が結合層で動作確認
- [ ] Service Object の Result が統一されている

### 安定性
- [ ] transactional fixtures で安定
- [ ] flaky なし

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] 結合テストで複数機能のシナリオを通すケースがあるか (機能 A → 機能 B の連動)
- [ ] DB / 外部システムの使い方が機能間で一貫 (片方が実物、片方がモックの不均衡なし)
- [ ] CI 全体の結合テスト実行時間が許容範囲内か
