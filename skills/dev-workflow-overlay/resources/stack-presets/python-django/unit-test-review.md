# unit-test-review — python-django rules

## REVIEW_EXTRAS

> 検証対象 = **詳細設計**。UNIT テスト層の python-django 固有レビュー観点。

### 実施網羅性
- [ ] pytest-django で全単体ケースが実行
- [ ] skip / xfail に reason

### カバレッジ (単体)
- [ ] 行カバレッジ 85% / 分岐 80% 以上
- [ ] `pytest --cov-branch` で計測

### 単体テスト固有
- [ ] Django の TestCase ではなく pytest 関数スタイル
- [ ] @pytest.mark.django_db の付け忘れなし
- [ ] factory-boy 使用、fixtures (yaml/json) は使わない
- [ ] service / model / serializer / view の各層にカバレッジ分散

### 安定性
- [ ] flaky なし
- [ ] シグナル / async / Celery 経路で副作用が漏れない

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか (一部機能だけ大幅未達)
- [ ] 共通モジュール (`*-common/`, `core/` 等) のテストが個別機能テストに重複していないか
- [ ] CI 全体の単体テスト実行時間が許容範囲内か
- [ ] モック対象が機能間で一貫している (同じ外部依存を機能ごとに違う方法でモックしていないか)
