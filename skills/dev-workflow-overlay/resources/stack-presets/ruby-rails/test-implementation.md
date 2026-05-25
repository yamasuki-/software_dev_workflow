# test-implementation — Ruby on Rails rules

## ADD
- RSpec (`rspec-rails`) を推奨。Minitest 採用時は別途 project 層で明文化
- 配置:
  - Model: `spec/models/<resource>_spec.rb`
  - Service: `spec/services/<domain>/<verb>_<noun>_spec.rb`
  - Controller / API: `spec/requests/<resource>_spec.rb` (request spec を使用、controller spec は使わない)
  - System: `spec/system/<flow>_spec.rb` (Capybara + Cuprite)
  - Job: `spec/jobs/<job>_spec.rb`
- factory_bot で fixture を表現 (`spec/factories/<resource>.rb`)
  - traits を活用し、データのバリエーションを命名で表現
- WebMock + VCR で外部 HTTP モック
  - VCR cassette は `spec/vcr_cassettes/` に保存、CI で再生
- Database Cleaner は基本不要 (Rails の transactional fixtures + system spec のみ truncate)
- 命名:
  - `describe "#メソッド" do` / `context "条件" do` / `it "期待結果"` の階層
  - `RSpec.describe ClassName, type: :request` などの type 明示
- 共通 helper: `spec/support/` に集約 (`Rails.root.join('spec/support/**/*.rb').each { |f| require f }` を `rails_helper.rb` で読む)

## OVERRIDE
- 「Red 確認」→ `bundle exec rspec --fail-fast` で 1 件目失敗時に停止し、出力を Red 確認ログに貼付

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `spec/factories/<resource>.rb`
- `spec/support/<helper>.rb`
- `spec/vcr_cassettes/<group>/<name>.yml`
- `docs/04_test_results/<FID>/red-confirmation.md`

## REVIEW_EXTRAS
- request spec を使い、controller spec を新規追加していないか
- system spec が必要な flow に対して書かれているか
- FactoryBot の traits が活用され、データ生成が読みやすいか
- VCR cassette が機密を含んでいないか (Authorization ヘッダのフィルタ設定)
- 共通 helper が `spec/support/` に整理されているか
- Red 確認時に require / autoload 失敗が混ざっていないか
