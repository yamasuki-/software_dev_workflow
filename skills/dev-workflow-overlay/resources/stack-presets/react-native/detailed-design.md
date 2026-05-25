# detailed-design — React Native rules

## ADD
- 画面 (screen) は `app/` の Expo Router ファイル構造で表現し、`screen-map.md` に一覧
  - Stack / Tab / Modal の階層を明示
  - 各 screen の遷移元 / 遷移先 / params の型を明記
- 機能 (FID) ごとに `src/features/<feature>/` を切る (components / hooks / api / schemas)
- データ取得は **TanStack Query hook** に統一
  - offline 戦略 (`networkMode: 'offlineFirst'` 等) を機能ごとに明示
  - キャッシュ永続化 (persistQueryClient + AsyncStorage) の要否
- ネイティブモジュールの使用 (Camera / Location / Notifications 等) は **必要 permission と利用シーン** を `native-modules.md` に列挙
- フォームは react-hook-form + zod
- スタイリングは NativeWind か StyleSheet (project で一貫)
- アクセシビリティ:
  - `accessibilityLabel` / `accessibilityRole` / `accessibilityHint` の要件を主要 UI 要素に明記
  - VoiceOver / TalkBack 双方で動作する設計
- 機種・OS 差:
  - iOS / Android の挙動差を `detailed-design` に明示 (例: keyboard avoidance、status bar、notch)
  - Safe Area 適用方針

## OVERRIDE
- 「機能設計シーケンス図」→ Mermaid sequenceDiagram で `User / Screen / Hook / Native Module / API / Backend` の lane を必須

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/screen-map.md`
- `docs/02_detailed_design/<FID>/queries.md`
- `docs/02_detailed_design/<FID>/native-modules.md`
  - 使用するネイティブ機能、要求 permission、初回権限要求のタイミング
- `docs/02_detailed_design/<FID>/a11y-design.md`
- `docs/02_detailed_design/<FID>/ui-design.md` に画面イメージ (テキストで構造記述、可能なら Figma リンク)

## REVIEW_EXTRAS
- screen の params 型が定義されているか (Expo Router の typed routes 活用)
- TanStack Query の offline 戦略が機能要件に合致
- ネイティブ permission の取得タイミングが UX 要件に合致 (初回アクセス時 / 設定画面など)
- a11y 要件が主要 UI 要素に行き渡っているか
- iOS / Android 差分が設計時点で識別されているか
- modal / sheet / drawer の遷移が stateDiagram で図示されているか
