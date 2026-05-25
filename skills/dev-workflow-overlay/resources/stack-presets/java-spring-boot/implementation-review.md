# implementation-review — Java + Spring Boot rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析・ビルド
- [ ] `./gradlew spotlessCheck` が 0 件
- [ ] `./gradlew checkstyleMain checkstyleTest` が 0 件
- [ ] ErrorProne / SpotBugs 警告が 0 件
- [ ] `./gradlew compileJava compileTestJava` 警告 0
- [ ] `./gradlew dependencyUpdates` で重大なセキュリティ更新が放置されていない

### DI と immutability
- [ ] constructor injection のみ (field / setter injection なし)
- [ ] フィールドが `final`
- [ ] DTO が record で immutable

### Transaction / JPA
- [ ] `@Transactional` が Service にのみ付与
- [ ] `readOnly = true` を読み取り処理に適用
- [ ] `@EntityGraph` / fetch join で N+1 を回避
- [ ] `cascade = ALL` の濫用なし
- [ ] equals/hashCode が ID 遅延ロードで NPE を起こさない実装

### セキュリティ
- [ ] SecurityFilterChain が `@Configuration` で明示構築
- [ ] method-level `@PreAuthorize` が必要箇所に
- [ ] secrets が環境変数経由 (`${ENV:default}`)
- [ ] CSRF / CORS 設定が要件と一致
- [ ] Actuator endpoints が production で保護されている

### 例外・ログ
- [ ] ドメイン例外が `@RestControllerAdvice` で Problem Details に変換
- [ ] `RuntimeException` の握りつぶしがない
- [ ] log に PII が出ていない
- [ ] log が構造化 (key/value) されている

### Spring 機能の正しい使用
- [ ] `@Async` を使う場合 `Executor` を明示
- [ ] virtual threads が有効 (`spring.threads.virtual.enabled=true`)
- [ ] `@Cacheable` の TTL / 無効化方針が明示

### Flyway / migration
- [ ] forward only (修正は別 migration で)
- [ ] migration 番号が衝突していない (タイムスタンプ命名推奨)
- [ ] データ移行は別 SQL に分離

### 横断 (cross) モード追加観点
- [ ] DTO record が機能間で重複定義されていないか (共通化検討)
- [ ] `@RestControllerAdvice` のハンドラが分散していないか (1 つに集約)
- [ ] Security 設定が全機能で一貫
- [ ] パッケージ間の循環依存がないか (`./gradlew checkDependencies` 等)
- [ ] application-*.yml の値が機能ごとに散らばっていないか
