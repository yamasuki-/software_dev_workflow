# Stack Config — Ruby on Rails

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       Ruby 3.4 (YJIT 推奨、`RUBY_YJIT_ENABLE=1`)
- パッケージマネージャ:       Bundler (`Gemfile` + `Gemfile.lock` を必ずコミット)
- Node:                       Node.js 22 LTS (importmap でも esbuild でも、フロント周りで必要)

## フレームワーク
- フレームワーク:             Rails 8.x (Solid Queue / Solid Cache / Solid Cable など Rails 8 標準を活用)
- フロント:                   Hotwire (Turbo + Stimulus) を第一選択
- ビュー:                     ERB (View Component を必要時導入)
- ORM:                        ActiveRecord
- DB:                         PostgreSQL 16+
- マイグレーション:           Rails migration (`db/migrate/<timestamp>_*.rb`)
- バリデーション:             ActiveModel::Validations (model 内) + 必要に応じて Form Object
- 認証:                       Rails 8 標準の bcrypt + has_secure_password、または Devise (好み)
- 認可:                       Pundit または CanCanCan
- ジョブ:                     ActiveJob + Solid Queue (Rails 8 デフォルト)
- メール:                     ActionMailer
- 設定:                       Rails.application.credentials + ENV (`config/credentials/*.yml.enc`)

## コーディング規約 (スタック標準)
- フォーマッタ / リンタ:      RuboCop (rubocop-rails, rubocop-performance, rubocop-rspec)
- 静的解析:                   Brakeman (セキュリティ) を CI で実行
- 命名規則:                   Rails 慣習 (model 単数 PascalCase / table 複数 snake_case / controller 複数 PascalCase)
- ディレクトリレイアウト規約: 標準 Rails + `app/services/` / `app/queries/` / `app/forms/` 拡張

### 推奨ディレクトリレイアウト
```
app/
├─ controllers/
├─ models/
├─ views/
├─ helpers/
├─ services/           ← ビジネスロジック (Service Object)
├─ queries/            ← 複雑な検索 (Query Object)
├─ forms/              ← 複数 model にまたがる入力 (Form Object)
├─ jobs/
├─ mailers/
├─ components/         ← ViewComponent (使う場合)
└─ javascript/         ← Stimulus controllers
config/
├─ routes.rb
├─ environments/
└─ credentials/
db/
├─ migrate/
└─ schema.rb
spec/  または test/
```

## テスト基盤 (スタック標準)
- テストランナー:             RSpec (`rspec-rails`) を推奨 (Minitest でも可、project 層で選択)
- フィクスチャ:               FactoryBot (`factory_bot_rails`)
- DB クリーニング:            transactional fixtures (RSpec の `use_transactional_fixtures`) を基本、JS テストのみ truncate
- システムテスト:             Rails system tests (Capybara + Selenium / Cuprite)
- API テスト:                 request spec (RSpec) / integration test (Minitest)
- モック:                     RSpec mocks 基本、WebMock + VCR で外部 HTTP モック
- 命名規則:                   `spec/<層>/<対象>_spec.rb` (RSpec) / `test/<層>/<対象>_test.rb` (Minitest)
- カバレッジ計測ツール:       SimpleCov
- カバレッジ目標 (スタック既定): 行 85% / 分岐 75% (SimpleCov に branch coverage を有効化)

## ロギング / 監視 (スタック標準)
- ログ:                       Rails.logger (Lograge で JSON 整形を推奨)
- 構造化:                     Lograge + lograge-sql (本番では JSON)
- request_id:                 ActionDispatch::RequestId (デフォルト) + log_tags
- メトリクス:                 yabeda-prometheus (or DataDog)
- エラートラッキング:         Sentry (sentry-ruby + sentry-rails)
- パフォーマンス監視:         Skylight / DataDog / New Relic (project 選定)

## エラー処理パターン (スタック標準)
- ApplicationController で `rescue_from` を集約:
  - ActiveRecord::RecordNotFound → 404
  - Pundit::NotAuthorizedError → 403
  - 独自ドメイン例外 → 適切な status + Problem Details
- レスポンス書式:             API は RFC 7807 Problem Details
- バリデーションエラー:       Form Object / model errors を 422 + Problem Details にマップ

## CI/CD ツール
- CI:                         GitHub Actions
- 必須チェック:
  1. `bundle install`
  2. `bundle exec rubocop`
  3. `bundle exec brakeman -q --no-pager`
  4. `bundle exec erb_lint --lint-all` (ERB を使う場合)
  5. `bundle exec rspec` (または `bin/rails test`)
  6. `bundle exec rake assets:precompile` (デプロイビルドで)

## ADD (スタック由来の追加ルール)
- Fat Controller / Fat Model を避ける
  - ビジネスロジックは Service Object (`app/services/`) に切り出す
  - 複雑な検索は Query Object (`app/queries/`)
  - 複数 model にまたがる入力は Form Object (`app/forms/`)
- N+1 を避ける (`includes` / `preload` / `eager_load` を明示、`bullet` gem を development で有効化)
- 認可は **必ず** Pundit / CanCanCan を経由 (Controller 直書きの `if current_user.admin?` 禁止)
- `find_each` で大量レコード処理、`find` 単発で N 件ループ禁止
- 機密は `Rails.application.credentials` または ENV (.env はコミットしない)
- マイグレーションは forward only、データ移行は別 migration に分離
- `update_columns` / `update_column` などコールバックスキップ系は意図して使い、コメントを残す

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「DB 設計を ER 図で記述」→ ActiveRecord schema + migration を真とし、ER 図は主要 FK のみ Mermaid erDiagram で記述
- 「機能設計シーケンス図にレイヤを記載」→ `Client / Routes / Controller / Service / Model / DB` の lane を必須

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `db/migrate/<timestamp>_<FID>_*.rb`
- `docs/02_detailed_design/<FID>/active-record-models.md` (主要 Model と関連、scope)
- API がある場合 `docs/02_detailed_design/<FID>/api-schema.yaml` (rswag 等で生成)

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- Fat Controller / Fat Model になっていないか (Service / Query / Form に分離されているか)
- N+1 が発生していないか (bullet で 0 件か)
- Strong Parameters が controller で適切に定義されているか
- 認可が Pundit / CanCanCan 経由か
- `update_columns` などコールバックスキップにコメントがあるか
- secrets が credentials または ENV 経由か
- Brakeman 警告が 0 件か
