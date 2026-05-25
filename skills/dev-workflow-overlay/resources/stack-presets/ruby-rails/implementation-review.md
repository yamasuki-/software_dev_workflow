# implementation-review — Ruby on Rails rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析・セキュリティ
- [ ] `bundle exec rubocop` が 0 件
- [ ] `bundle exec brakeman -q` が 0 件 (既知の例外には注釈)
- [ ] `bundle exec erb_lint --lint-all` が 0 件 (ERB 使用時)
- [ ] `bundle audit check --update` で重大脆弱性 0 件
- [ ] `bundle outdated` で重大なバージョン乖離なし

### レイヤ分離
- [ ] Fat Controller / Fat Model になっていない (Service / Query / Form に分離)
- [ ] Service Object が Result オブジェクトを返す形で統一されている
- [ ] callback (after_save 等) を新規追加していない (Service へ)
- [ ] Controller の 1 action が 1 Service 呼び出し中心

### Strong Parameters / 認可
- [ ] Strong Parameters の許可キーが必要十分
- [ ] mass assignment 脆弱性がない
- [ ] Pundit / CanCanCan による認可が全 action で実施 (skip は理由明示)
- [ ] `current_user` 直比較 (`if current_user.admin?`) が controller にない

### N+1 / DB
- [ ] `bullet` で N+1 検知 0 件
- [ ] `find_each` / `in_batches` が大量処理で使用
- [ ] `update_columns` 等コールバックスキップにコメントあり
- [ ] scope に副作用がない

### 設定・機密
- [ ] secrets が credentials / ENV 経由 (.env をコミットしていない)
- [ ] `filter_parameters` で PII / token がログから除外されている
- [ ] CSRF / CORS / cookie settings が要件と一致

### Hotwire
- [ ] Turbo Frame / Stream の id が衝突していない
- [ ] Stimulus controller の data-* attribute が宣言的
- [ ] Turbo Stream broadcast を使う場合、認可境界を意識している

### 例外・ログ
- [ ] ApplicationController で `rescue_from` 集約
- [ ] ドメイン例外を握りつぶしていない
- [ ] log が Lograge で構造化、PII が除外されている

### 横断 (cross) モード追加観点
- [ ] Service Object の Result 型が機能間で統一されているか
- [ ] 同等の Query Object / Form Object が複数機能で別実装されていないか
- [ ] Pundit policy の継承関係が一貫しているか
- [ ] ApplicationController の `rescue_from` が一箇所に集約されているか
- [ ] db schema の命名規則が機能間で一貫しているか
