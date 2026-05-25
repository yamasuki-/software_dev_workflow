# testing-review — Ruby on Rails rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 実施網羅性
- [ ] テスト設計の全ケースが RSpec で実行されている
- [ ] skip / pending に reason がある
- [ ] CI が緑

### カバレッジ
- [ ] 行 85% / 分岐 75% (スタック既定)
- [ ] SimpleCov `coverage/index.html` が `docs/04_test_results/<FID>/` にある
- [ ] Model / Service / Controller / Query / Form それぞれにカバレッジが分散

### system spec / E2E
- [ ] 主要 flow が system spec で網羅されている
- [ ] Cuprite headless で安定実行 (flaky なし)
- [ ] スクリーンショット (失敗時) が CI で取得される

### Request spec
- [ ] 認証 / 認可境界 (200 / 401 / 403) のテストがある
- [ ] Strong Parameters の境界 (許可外キーが ignored される) がテストされている
- [ ] レスポンス形式 (JSON / HTML / Turbo Stream) が assert されている

### VCR / WebMock
- [ ] 外部 HTTP がすべて WebMock + VCR で stub されている
- [ ] cassette に機密 (Authorization / Cookie) が含まれていない (filter 設定)
- [ ] cassette 再録のタイミングが明示されている

### パフォーマンス
- [ ] slow test の上位 10 件が許容内 (`--profile=10`)
- [ ] factory_bot のレコード生成が肥大していないか (`create` を `build` / `build_stubbed` で代替検討)

### 不具合
- [ ] 不具合票が作成されている
- [ ] failing spec の出力 (`bundle exec rspec --format doc`) が添付

### 横断 (cross) モード追加観点
- [ ] 機能間でカバレッジに極端な偏りがないか
- [ ] FactoryBot factory が機能間で重複・矛盾していないか
- [ ] system spec の helper / page object が共通化されているか
- [ ] CI 全体の RSpec 実行時間が許容範囲か
- [ ] DatabaseCleaner 戦略が機能間で一貫しているか
