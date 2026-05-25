# implementation — Ruby on Rails rules

## ADD
- ビジネスロジックは Service Object に集約:
  - `app/services/<domain>/<verb>_<noun>.rb`
  - クラスメソッド `.call(...)` を public entry にし、internal はインスタンスメソッド
  - Result オブジェクトを返す (`Result.success(value)` / `Result.failure(errors)`)
- Controller:
  - Strong Parameters で許可キーを明示 (`params.require(:user).permit(:email, :name)`)
  - 認可: Pundit (`authorize @resource`) または CanCanCan
  - skip_authorization が必要なら理由をコメントで明記
  - 1 action = 1 Service 呼び出しが目安、複数 Service を直列でつなげない
- ActiveRecord:
  - `includes` / `preload` / `eager_load` を N+1 防止に明示
  - `find_each` / `in_batches` で大量レコード処理 (デフォルト batch_size 1000)
  - callback の濫用を避ける (副作用は Service で明示呼び出し)
  - `update_columns` / `update_column` 使用時はコメント必須
  - scope は副作用なし (副作用ありは Query Object / Service)
- Strong Parameters の戻り値を直接 model に渡さず、Form Object または Service の引数として渡す
- 機密:
  - `Rails.application.credentials.dig(:service, :key)` または ENV
  - `.env` 系を使う場合は dotenv-rails、commit 禁止 (.gitignore)
- ログ:
  - Lograge で構造化
  - `Rails.logger.tagged("FID")` でコンテキスト付与
  - PII を log に出さない (`filter_parameters` 設定)
- Hotwire:
  - Turbo Stream / Frame の id 衝突に注意
  - Stimulus controller は値・ターゲット・アクションを宣言的に書く
- 例外:
  - ApplicationController で `rescue_from` を集約 (詳細は project 層)
  - ドメイン例外を握りつぶさない

## OVERRIDE
- ベース「最小実装で Green」→ Rails では migration / FactoryBot factory / Service skeleton が test-implementation 段階で先に定義済みである前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は app/ 配下に出力)

## REVIEW_EXTRAS
- `bundle exec rubocop` が 0 件
- `bundle exec brakeman` が 0 件 (or 既知の例外のみ)
- N+1 が出ていないか (`bullet` gem が development / test で有効)
- Fat Controller / Fat Model が再発していないか (Service / Query / Form に分離)
- Strong Parameters の漏れ (mass assignment 脆弱性) がないか
- 認可漏れ (Pundit / CanCanCan の skip) がないか
- `update_columns` 等コールバックスキップにコメントがあるか
- secrets が credentials / ENV 経由で `.env` をコミットしていないか
- callback (`after_save` 等) を新規追加していないか (Service へ)
- PII が log に出ていないか (`filter_parameters` 確認)
