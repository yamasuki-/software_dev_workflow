# detailed-design — Ruby on Rails rules

## ADD
- 機能を Rails resource 単位で設計し、routes / controller / model / service / form / query の対応を明示
- ビジネスロジックは Service Object (`app/services/<Domain>/<Verb><Noun>.rb`) として PORO (Plain Old Ruby Object) で書く
  - インタフェース: `Domain::CreateUser.call(params:, current_user:)` の class method 呼び出し
  - 戻り値: Result オブジェクト (success?, value, errors) を統一
- 複雑検索は Query Object (`app/queries/<Resource>Query.rb`) に切り出し scope のチェーン任せにしない
- 複数 model にまたがる入力は Form Object (`app/forms/<Action><Resource>Form.rb`) で受ける (ActiveModel::Model include)
- ActiveRecord Model:
  - validation / association / scope のみ持つ
  - ビジネスルールは Service へ
  - callback (`after_save` 等) を最小限にし、副作用ロジックは Service で明示呼び出し
- Controller:
  - Strong Parameters で許可キーを明示
  - 認可は Pundit (`authorize @user`) を before_action または各 action で実行
  - 失敗パスは `rescue_from` または明示 `render` で Problem Details に変換
- Hotwire (Turbo + Stimulus):
  - 部分更新は Turbo Frame / Turbo Stream で表現
  - クライアント側ロジックは Stimulus controller (`app/javascript/controllers/`)
- API モード (API only) の場合:
  - JSON シリアライザは Jbuilder / alba / blueprinter から 1 つ選定 (project 層で確定)

## OVERRIDE
- 「機能設計シーケンス図」→ Mermaid sequenceDiagram で `Client (Turbo) / Routes / Controller / Service / Model / DB` の lane を必須
- 「DB 設計を ER 図で記述」→ 設計の正は **Mermaid erDiagram (主要 FK) + カラム定義表** (型 / null / PK / FK / index / 制約)。ActiveRecord schema / migration は **実装フェーズで本設計から作成** する (設計書にコードは書かない)

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/active-record-models.md` (Model / association / scope を **表で記述**。ActiveRecord コードは書かない。実装フェーズで本仕様から作成)
- `docs/02_detailed_design/<FID>/service-objects.md` (Service の入力 / Result / 呼び出し元)
- `docs/02_detailed_design/<FID>/views-and-turbo.md` (使用する Turbo Frame / Stream、Stimulus controller)
- API モード時 `docs/02_detailed_design/<FID>/api-schema.yaml`

## REVIEW_EXTRAS
- ビジネスロジックが Controller / Model に染み出していないか
- Service Object の Result が統一されているか
- Strong Parameters が正しく定義されているか (mass assignment 脆弱性なし)
- 認可方針が全 action にあるか (skip がある場合は明示理由)
- Turbo Frame / Stream の id 衝突がないか
- N+1 を起こしうる検索が Query Object に切り出されているか
