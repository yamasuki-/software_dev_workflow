# Stack Config — React Native (Expo SDK)

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。
> 本プリセットは **Expo SDK + Expo Router** ベースを推奨 (Bare workflow も併用可)。

## 言語・処理系
- 言語:                       TypeScript 5.7 (strict)
- React Native:               0.76+ (New Architecture: Fabric / TurboModules 有効)
- Expo SDK:                   52+ (Expo Router 4+)
- ランタイム (開発):          Node.js 22 LTS
- パッケージマネージャ:       pnpm または yarn (Metro との互換性を確認)
- 依存解決:                   lock ファイルをコミット

## フレームワーク
- ルーティング:               Expo Router (file-based)
- 状態管理:                   Zustand (グローバル) + React Context (狭スコープ)
- データ取得 / キャッシュ:    TanStack Query v5
- HTTP クライアント:          fetch + ラッパ
- フォーム / バリデーション:  react-hook-form + zod
- スタイリング:               NativeWind (Tailwind for RN) または StyleSheet.create
- アイコン:                   lucide-react-native または @expo/vector-icons
- ナビゲーション内蔵:         react-navigation (Expo Router の基盤)
- ストレージ:                 expo-secure-store (機密) + AsyncStorage (非機密)
- 認証:                       expo-auth-session または Clerk / Auth0 SDK
- プッシュ通知:               expo-notifications
- カメラ / 画像:              expo-camera / expo-image-picker

## コーディング規約 (スタック標準)
- フォーマッタ:               Prettier
- リンタ:                     ESLint (`@typescript-eslint`, `eslint-plugin-react`, `eslint-plugin-react-native`, `eslint-plugin-react-hooks`)
- 型チェッカ:                 `tsc --noEmit`
- 命名規則:                   ファイル kebab-case、コンポーネント PascalCase、hooks camelCase
- ディレクトリレイアウト規約: Expo Router 構造 + features 分離

### 推奨ディレクトリレイアウト
```
app/                          ← Expo Router (file-based routing)
├─ (tabs)/
├─ (auth)/
├─ _layout.tsx
└─ +not-found.tsx
src/
├─ features/                  ← 機能 (FID) ごと
│   └─ <feature>/
│       ├─ components/
│       ├─ hooks/
│       ├─ api/
│       └─ schemas/
├─ components/                ← 横断 UI
├─ lib/                       ← api client / storage / formatters
├─ hooks/                     ← 横断 hooks
├─ store/                     ← Zustand
├─ types/
└─ env.ts                     ← 環境変数 (zod parse)
assets/
├─ images/
└─ fonts/
```

## テスト基盤 (スタック標準)
- テストランナー:             Jest (`jest-expo` preset) を強く推奨
  - Vitest は React Native のネイティブモジュール解決が不安定なため非推奨
- DOM テスト:                 @testing-library/react-native + @testing-library/jest-native
- API モック:                 msw (Node mode)
- E2E:                        Maestro (推奨、YAML 記述で簡潔) または Detox (Bare workflow 必須機能あり)
- 命名規則:                   `<対象>.test.ts(x)`
- カバレッジ計測ツール:       Jest built-in (`--coverage`)
- カバレッジ目標 (スタック既定): 行 75% / 分岐 65% (UI が重く目標は控えめ)

## ロギング / 監視 (スタック標準)
- ログ:                       `console.log` は dev のみ。本番は Sentry
- エラートラッキング:         Sentry (`@sentry/react-native`)
- 計測:                       expo-analytics / firebase-analytics などプロジェクト要件で選択
- クラッシュレポート:         Sentry または Firebase Crashlytics

## エラー処理パターン (スタック標準)
- API: fetch ラッパでステータス変換 → ドメイン error
- UI: react-error-boundary でルート / route 境界に Error Boundary
- ネットワーク断: 各 query で `isOffline` ハンドリング (TanStack Query の `networkMode`)

## CI/CD ツール
- CI:                         GitHub Actions
- ビルド:                     EAS Build (Expo Application Services)
- 配布:                       EAS Submit (App Store / Google Play)、internal は EAS Update (OTA)
- 必須チェック:
  1. `pnpm install --frozen-lockfile`
  2. `pnpm typecheck`
  3. `pnpm lint`
  4. `pnpm format:check`
  5. `pnpm test`
  6. `eas build --platform all --profile preview` (PR 用、必要時)

## ADD (スタック由来の追加ルール)
- API 通信は **TanStack Query 経由のみ**
- 環境変数は `src/env.ts` (zod parse) を経由のみ
  - クライアント露出する性質なので機密はそもそも持ち込まない
  - 機密が必要なら自前 BFF を別途用意し、そこで持つ
- 機密ストレージは expo-secure-store、非機密は AsyncStorage
- Image は expo-image を優先 (キャッシュ / placeholder)
- ナビゲーションは Expo Router の `<Link>` / `router.push` を使い、Linking API 直接使用は限定
- プラットフォーム差分は `Platform.select` / `.ios.tsx` / `.android.tsx` で表現
- アクセシビリティ: `accessibilityLabel` / `accessibilityRole` / `accessibilityHint` を主要操作に必須
- 機種差: SafeAreaView / safe-area-context を必ず適用

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「画面遷移図必須」→ Expo Router の file 構造一覧 + Mermaid stateDiagram (Modal / Sheet 等 overlay 遷移のみ)
- 「機能設計シーケンス図」→ App / Native Module / API / Backend の 4 lane を必須

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/screen-map.md` (関連 screen / route の一覧、tab/stack 構造)
- `docs/02_detailed_design/<FID>/queries.md` (TanStack Query の queryKey / staleTime / offline 戦略)
- `docs/02_detailed_design/<FID>/native-modules.md` (使用するネイティブモジュール、permission 一覧)
- `docs/02_detailed_design/<FID>/a11y-design.md` (a11y 要件)

## 自動チェック (MUST / SHOULD / MAY)

auto-check スキルが本セクションを読み、各フェーズの直前に MUST/SHOULD/MAY を順次実行する。
React Native は Jest を既定としているが、project-config.md で Vitest を選んだ場合はコマンドを差し替える。

### 全フェーズ共通

#### MUST
- markdownlint-cli2 "**/*.md" "#node_modules"   # install: npm install -g markdownlint-cli2
- bash ~/.claude/skills/auto-check/resources/scripts/check-mermaid.sh .   # install: npm install -g @mermaid-js/mermaid-cli

#### SHOULD
- textlint docs/**/*.md   # install: npm install -g textlint textlint-rule-preset-ja-technical-writing
- typos --no-check-filenames .   # install: cargo install typos-cli

#### MAY
- lychee --no-progress "**/*.md"   # install: cargo install lychee

### test-implementation 固有

#### MUST
- pnpm jest --listTests
- pnpm jest --bail   # 期待: 全テスト Red

#### SHOULD
- (なし)

#### MAY
- (なし)

### implementation 固有

#### MUST
- pnpm typecheck   # = tsc --noEmit
- pnpm lint        # = eslint . (react-native plugin 有効)
- pnpm format:check
- pnpm expo doctor   # install: pnpm add -D expo (バージョン整合チェック)

#### SHOULD
- pnpm audit --audit-level=high
- semgrep --config=p/typescript --error .   # install: pip install semgrep

#### MAY
- jscpd src/ app/   # install: npm install -g jscpd

### testing 固有

#### MUST
- pnpm jest --coverage --ci

#### SHOULD
- (Maestro / Detox は実機/シミュレータ環境が必要。CI で別 job として扱うのが現実的)

#### MAY
- pnpm maestro test e2e/maestro/   # install: https://maestro.mobile.dev (ローカル+CI 設定要)
- npx --yes detox test --configuration ios.sim.release   # Detox 採用時

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- `accessibilityLabel` / `Role` が主要操作にあるか
- SafeAreaView 適用が漏れていないか
- iOS / Android の差分が `Platform.select` または `.ios/.android` ファイル分岐で正しく扱われているか
- expo-secure-store と AsyncStorage の使い分けが妥当か (機密の取り違えがないか)
- 必要な permission が `app.json` (expo) に宣言されているか
- バンドル / アセットサイズの肥大化がないか
