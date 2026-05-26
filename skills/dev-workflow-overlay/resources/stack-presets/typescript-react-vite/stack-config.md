# Stack Config — TypeScript + React + Vite (SPA)

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。
> 本プリセットは **SPA (バックエンド API は別リポジトリ)** を想定。

## 言語・処理系
- 言語:                       TypeScript 5.7 (strict + noUncheckedIndexedAccess: true)
- ランタイム (開発/ビルド):   Node.js 22 LTS
- パッケージマネージャ:       pnpm
- 依存解決:                   `pnpm-lock.yaml` をコミット、`pnpm install --frozen-lockfile` を CI で使用

## フレームワーク
- ビルダ:                     Vite 5.x または 6.x
- ライブラリ:                 React 19.x + React DOM
- ルーティング:                React Router 7.x (data router 推奨) または TanStack Router
- 状態管理:                   Zustand (グローバル状態) + React Context (狭いスコープ)
- データ取得 / キャッシュ:    TanStack Query (旧 React Query) v5
- HTTP クライアント:          ofetch または fetch ラッパ (axios は避ける、必要時のみ)
- フォーム / バリデーション:  react-hook-form + zod
- スタイリング:               Tailwind CSS 4.x (デフォルト) + shadcn/ui
- アイコン:                   lucide-react
- ユーティリティ:             date-fns / clsx / cva

## コーディング規約 (スタック標準)
- フォーマッタ:               Prettier
- リンタ:                     ESLint (`@typescript-eslint`, `eslint-plugin-react`, `eslint-plugin-react-hooks`, `eslint-plugin-tailwindcss`)
- 型チェッカ:                 `tsc --noEmit` (CI 必須)
- 命名規則:                   ファイル kebab-case、コンポーネント PascalCase、hooks `useXxx`、関数 camelCase
- ディレクトリレイアウト規約: features 分離

### 推奨ディレクトリレイアウト
```
src/
├─ main.tsx                ← エントリポイント
├─ App.tsx                 ← ルータ組み立て
├─ routes/                 ← ルート定義 (React Router) / または config 形式
├─ features/               ← 機能 (FID) ごとに切る
│   └─ <feature>/
│       ├─ components/
│       ├─ hooks/
│       ├─ api/            ← TanStack Query hooks (use<X>Query / use<X>Mutation)
│       ├─ schemas/        ← zod
│       └─ index.ts        ← 公開 API (barrel)
├─ components/             ← 横断 UI (shadcn/ui 含む)
│   └─ ui/
├─ lib/                    ← 汎用ユーティリティ (api client / formatters)
├─ hooks/                  ← 横断 hooks
├─ store/                  ← Zustand store
├─ types/                  ← 横断型
└─ env.ts                  ← 環境変数 (import.meta.env を zod でパース)
```

## テスト基盤 (スタック標準)
- 単体・コンポーネント:       Vitest または Jest (project 層で選定)
  - Vitest 推奨 (Vite との統合が良い)
  - Jest を選ぶ場合は `@swc/jest` + `jest-environment-jsdom`
- DOM 環境:                   jsdom または happy-dom
- DOM テスト:                 @testing-library/react + @testing-library/user-event
- API モック:                 msw (Mock Service Worker)
- E2E:                        Playwright
- 命名規則:                   `<対象>.test.ts(x)` (同ディレクトリ) または `__tests__/`
- カバレッジ計測ツール:       Vitest の `--coverage` (v8 provider) または Jest built-in
- カバレッジ目標 (スタック既定): 行 80% / 分岐 70% (UI は project 層で緩和許容)

## ロギング / 監視 (スタック標準)
- クライアントエラー:         Sentry (`@sentry/react`)
- 計測:                       Web Vitals (`web-vitals`) → 計測サービス送信
- ログ:                       `console.error` は dev のみ。本番は Sentry に送る

## エラー処理パターン (スタック標準)
- API レイヤ:
  - fetch / TanStack Query で error を Result 型または例外で扱う
  - HTTP エラーは status をドメイン error に変換
- UI:
  - Error Boundary (`<ErrorBoundary>` from react-error-boundary) をルート / route / suspense 境界に配置
  - toast 通知 (sonner) でユーザに伝達
  - 404 / 500 用の専用ページ

## CI/CD ツール
- CI:                         GitHub Actions
- デプロイ:                   静的ホスティング (Cloudflare Pages / Vercel / S3+CloudFront 等)
- 必須チェック:
  1. `pnpm install --frozen-lockfile`
  2. `pnpm typecheck`
  3. `pnpm lint`
  4. `pnpm format:check`
  5. `pnpm test`
  6. `pnpm test:e2e`
  7. `pnpm build`

## ADD (スタック由来の追加ルール)
- API 通信は **TanStack Query 経由のみ** (生 fetch を component 内で呼ばない)
  - `features/<feature>/api/use<Resource>Query.ts` の形で hook 化
- 環境変数は `src/env.ts` (zod でパース) を経由のみ、`import.meta.env` を直接読まない
  - クライアント露出するものに限られるため、機密はそもそも持ち込まない
- グローバル状態は最小化、可能なら TanStack Query のキャッシュで代替
- React の anti-pattern を避ける (useEffect での fetch、derived state の useState 保持 など)
- shadcn/ui コンポーネントは `components/ui/` にコピーして、必要なら edit する
- `key` の重複や index 使用を避ける

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「画面遷移図必須」→ React Router の route 定義表 + Mermaid stateDiagram (Modal / Drawer 等の overlay 遷移のみ)
- 「機能設計シーケンス図」→ Browser / Component / TanStack Query / API / Backend の 5 lane を必須

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/route-map.md` (該当機能で追加 / 変更する route 一覧)
- `docs/02_detailed_design/<FID>/zod-schemas.md` (form / API response の zod スキーマ)
- `docs/02_detailed_design/<FID>/queries.md` (TanStack Query の queryKey / staleTime / mutation 一覧)

## 自動チェック (MUST / SHOULD / MAY)

auto-check スキルが本セクションを読み、各フェーズの直前に MUST/SHOULD/MAY を順次実行する。
Vitest と Jest はどちらか採用したほうのコマンドだけを残すこと (project-config.md で選定)。

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
- pnpm vitest --run --reporter=verbose   # 期待: 全テスト Red (Vitest 採用時)
- # pnpm jest --listTests && pnpm jest --bail   # Jest 採用時

#### SHOULD
- (なし)

#### MAY
- (なし)

### implementation 固有

#### MUST
- pnpm typecheck   # = tsc --noEmit
- pnpm lint        # = eslint .
- pnpm format:check   # = prettier --check .
- pnpm build       # = vite build

#### SHOULD
- pnpm audit --audit-level=high
- semgrep --config=p/typescript --error .   # install: pip install semgrep

#### MAY
- jscpd src/   # install: npm install -g jscpd
- npx --yes size-limit   # bundle サイズ監視 (設定があれば)

### testing 固有

#### MUST
- pnpm vitest --run --coverage
- pnpm playwright test --reporter=list

#### SHOULD
- npx --yes vitest-axe   # a11y 単体 (設定があれば)

#### MAY
- npx --yes @axe-core/cli http://localhost:5173   # ローカル起動中の場合
- lighthouse-ci autorun

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- `import.meta.env` の直接アクセスがないか (`env.ts` 経由か)
- API 通信が TanStack Query 経由か (生 fetch を component に書いていないか)
- useEffect でデータ取得していないか (TanStack Query を使うべき箇所)
- Error Boundary が適切な粒度で配置されているか
- `key` の重複 / index 使用がないか
- `any` / `as` の濫用がないか
