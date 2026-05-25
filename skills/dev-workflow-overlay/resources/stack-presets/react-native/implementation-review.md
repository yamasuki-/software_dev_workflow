# implementation-review — React Native rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `pnpm typecheck` (`tsc --noEmit`) が 0 件
- [ ] `pnpm lint` が 0 件 (react-native プラグイン有効)
- [ ] `pnpm format:check` が 0 件

### React Native パターン
- [ ] API 通信が TanStack Query 経由 (生 fetch を component に書いていない)
- [ ] FlatList / SectionList が大量描画箇所で使われている (ScrollView 濫用なし)
- [ ] `getItemLayout` / `keyExtractor` が指定されている
- [ ] expo-image を使用 (生 `<Image>` 限定使用)
- [ ] Expo Router の typed routes を活用

### プラットフォーム・機種差
- [ ] `Platform.select` または `.ios/.android` 分岐で差分が表現されている
- [ ] SafeAreaView 適用漏れがない
- [ ] notch / status bar / keyboard avoidance の挙動が正しい

### アクセシビリティ
- [ ] `accessibilityLabel` / `accessibilityRole` / `accessibilityHint` が主要 UI に
- [ ] minimum touch target (44pt / 48dp) を満たす
- [ ] VoiceOver / TalkBack 動作確認

### ストレージ・セキュリティ
- [ ] 機密が expo-secure-store に、非機密が AsyncStorage に分けられている
- [ ] PII / token が `console.log` に出ていない
- [ ] env 直接アクセスがない (`env.ts` 経由)
- [ ] 機密を SPA 同様クライアント側に持ち込んでいない
- [ ] CSP / WebView の使用が安全か (loadHTMLString に user input 渡していないか)

### ネイティブ機能 / Permission
- [ ] 必要 permission が `app.json` (または `app.config.ts`) に宣言
- [ ] permission 要求のタイミングが UX 要件に合致
- [ ] permission 拒否時の代替フロー (Graceful degradation) が実装されている

### パフォーマンス
- [ ] バンドル / asset サイズが許容内
- [ ] 起動時間が NFR を満たす (実機計測)
- [ ] 重い計算が JS スレッドをブロックしていない (`InteractionManager.runAfterInteractions` / worklet 検討)

### 横断 (cross) モード追加観点
- [ ] features 間で同等の zod / TanStack Query hook / UI コンポーネントが重複していないか
- [ ] permission 宣言が `app.json` で一元管理されているか
- [ ] env スキーマが一箇所に集約されているか
- [ ] ナビゲーション構造 (tab / stack / modal) が全機能で一貫
