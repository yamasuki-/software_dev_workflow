# implementation — React Native rules

## ADD
- API 通信は TanStack Query 経由のみ
- 環境変数:
  - `src/env.ts` (zod parse) を経由のみ
  - 機密はクライアントに持ち込まない (公開と心得る)
  - 機密が必要なら BFF を別途用意し OAuth flow で扱う
- ストレージ:
  - 機密 (token / 個人情報) → expo-secure-store
  - 非機密 (UI state / cache) → AsyncStorage
- 画像:
  - expo-image を優先 (キャッシュ / placeholder / blurhash)
  - `<Image>` 直接使用は限定
- ナビゲーション:
  - Expo Router の `<Link>` / `router.push` / `router.replace`
  - params は typed routes を活用 (型安全)
  - Linking API 直接使用は deep link 受信のみ
- プラットフォーム差分:
  - `Platform.select({ ios: ..., android: ... })`
  - 大きく異なる場合は `.ios.tsx` / `.android.tsx` ファイル分岐
- SafeAreaView:
  - すべての画面で `react-native-safe-area-context` の `SafeAreaView` または `useSafeAreaInsets` を適用
- アクセシビリティ:
  - `accessibilityLabel` / `accessibilityRole` / `accessibilityHint` を主要 UI に
  - VoiceOver / TalkBack 双方で動作するよう minimum touch target (44pt / 48dp)
- パフォーマンス:
  - FlatList / SectionList を使う (ScrollView で大量描画しない)
  - `getItemLayout` / `keyExtractor` を必ず指定
  - 画像の `resizeMode` / `cachePolicy` を意識
- 機密ログ禁止:
  - PII / token を `console.log` に出さない (Sentry にも送らない)

## OVERRIDE
- ベース「最小実装で Green」→ RN では native module の mock 設定が test-implementation 段階で完了している前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は app/ / src/ 配下)

## REVIEW_EXTRAS
- `accessibilityLabel` / `Role` が主要 UI に付いているか
- SafeAreaView 適用漏れがないか
- 大量描画箇所で FlatList / SectionList を使用しているか
- expo-secure-store と AsyncStorage の使い分けが正しいか
- 必要 permission が `app.json` (または `app.config.ts`) に宣言されているか
- iOS / Android 差分が `Platform.select` / ファイル分岐で適切に扱われているか
- `console.log` で PII を出していないか
- env 直接アクセスがないか (`env.ts` 経由)
- バンドルサイズが許容内か (Sentry 等を含めて確認)
