# Stack Config — TypeScript + Next.js 15 (App Router)

> 同じ技術スタックを使う複数プロジェクトで再利用することを想定したスタック共通ルール。
> プロジェクト固有の事情は `project/project-config.md` 側に書く。

## 言語・処理系
- 言語:                       TypeScript 5.7 (strict + noUncheckedIndexedAccess: true)
- ランタイム:                 Node.js 22 LTS
- パッケージマネージャ:       pnpm (`packageManager` を `package.json` に固定)
- 依存解決:                   `pnpm-lock.yaml` をコミット、`pnpm install --frozen-lockfile` を CI で使用

## フレームワーク
- フレームワーク:             Next.js 15 (App Router 必須、Pages Router は不可)
- React:                      19.x
- スタイリング:               Tailwind CSS 4.x (デフォルト)、CSS Modules 併用可
- UI コンポーネント:          shadcn/ui (Radix ベース、コピー方式) を推奨
- フォーム / バリデーション:  react-hook-form + zod
- HTTP / データ取得:          fetch (RSC 標準) + React Query (クライアント側でキャッシュ要時)
- 認証:                       NextAuth.js (Auth.js) v5 または Clerk
- DB アクセス (BFF/server):   Prisma または Drizzle
- バリデーション (server):    zod
- 構造化ログ:                 pino (本番) / pretty (開発)
- 国際化:                     next-intl (必要時)

## コーディング規約 (スタック標準)
- フォーマッタ:               Prettier
- リンタ:                     ESLint (`eslint-config-next` + `@typescript-eslint` 推奨ルール + `eslint-plugin-tailwindcss`)
- 型チェッカ:                 `tsc --noEmit` (CI で必須)
- 命名規則:                   ファイル kebab-case (`user-profile.tsx`)、コンポーネント PascalCase、関数 camelCase
- ディレクトリレイアウト規約: app router 構造 + features 分離

### 推奨ディレクトリレイアウト
```
src/
├─ app/                       ← App Router (route segment)
│   ├─ (public)/
│   ├─ (app)/
│   ├─ api/
│   │   └─ <resource>/route.ts
│   ├─ layout.tsx
│   └─ page.tsx
├─ features/                  ← 機能 (FID) ごとに切る
│   └─ <feature>/
│       ├─ components/
│       ├─ hooks/
│       ├─ server/            ← server actions / data access
│       └─ schemas/           ← zod スキーマ
├─ components/                ← 横断 UI (shadcn/ui を含む)
│   └─ ui/
├─ lib/                       ← 共通ユーティリティ (auth / db / logger)
├─ server/                    ← サーバ専用 (db client, env, services)
│   ├─ db.ts
│   ├─ env.ts
│   └─ services/
└─ types/
```

## テスト基盤 (スタック標準)
- 単体・コンポーネント:       Vitest または Jest (project 層で選択)
  - Vitest: `vitest.config.ts` + jsdom or happy-dom
  - Jest:   `jest.config.ts` + `@swc/jest` + jest-environment-jsdom
- DOM テスト:                 @testing-library/react + @testing-library/user-event
- E2E:                        Playwright (CI で headless)
- API ルートテスト:           Vitest/Jest から直接 `route.ts` の handler を呼ぶ、または Playwright で実 HTTP
- モック:                     msw (Mock Service Worker) を fetch モックの第一選択
- 命名規則:                   `<対象>.test.ts(x)` または `<対象>.spec.ts(x)`
- カバレッジ計測ツール:       Vitest の `--coverage` (v8) または Jest の coverage
- カバレッジ目標 (スタック既定): 行 80% / 分岐 75% (UI コンポーネントは目標を緩める project 層上書き想定)

## ロギング / 監視 (スタック標準)
- ログ:                       pino (server 側のみ)
- クライアントエラー:         Sentry または Vercel Analytics
- ログ形式:                   JSON (本番) / pretty (dev)
- リクエスト ID:              middleware で生成し header / cookie に詰める

## エラー処理パターン (スタック標準)
- server actions / API ルート:
  - zod でリクエスト検証 → ドメイン関数 → Result 型 (`{ ok: true, data } | { ok: false, error }`) で返却
  - 例外はトップで catch し Problem Details に変換
- クライアント:
  - error.tsx / global-error.tsx を route segment ごとに配置
  - toast 通知 (sonner 等) でユーザに伝達

## CI/CD ツール
- CI:                         GitHub Actions
- デプロイ:                   Vercel または自前 Docker
- 必須チェック:
  1. `pnpm install --frozen-lockfile`
  2. `pnpm typecheck` (`tsc --noEmit`)
  3. `pnpm lint`
  4. `pnpm format:check`
  5. `pnpm test` (Vitest/Jest)
  6. `pnpm test:e2e` (Playwright)
  7. `pnpm build`

## ADD (スタック由来の追加ルール)
- App Router を必須とする (Pages Router の混在禁止)
- Server Component を既定とし、`'use client'` は必要箇所のみ明示
- データ取得は **Server Component または server actions** で行う (クライアント側 fetch は限定)
- 環境変数アクセスは `src/server/env.ts` (zod でバリデート) を経由のみ
  - `process.env` を直接読まない
  - クライアント露出する値は `NEXT_PUBLIC_` プレフィックス + 別 env スキーマ
- API ルート (`app/api/.../route.ts`) は薄く保ち、ロジックは `server/services/` に集約
- server actions の入力は **必ず zod でパース** してから処理
- 画像は `next/image`、フォントは `next/font` を使う

## OVERRIDE (ベース指示の置き換え — スタック由来)
- 「画面遷移図必須」→ App Router のディレクトリ構造で表現される範囲は Mermaid 不要 (該当ファイル一覧で代替)。複雑な遷移 (modal / parallel route) のみ Mermaid stateDiagram で記述
- 「機能設計シーケンス図」→ Server Action / API Route / RSC / Client の境界を必ず明示 (Mermaid sequenceDiagram の lane: Browser / Edge / Server Component / Server Action / DB)

## DISABLE (スタック由来)
- なし

## ADDITIONAL_ARTIFACTS (スタック由来の追加成果物)
- `docs/02_detailed_design/<FID>/route-map.md` (関連 route segment の一覧と説明)
- `docs/02_detailed_design/<FID>/zod-schemas.md` (server/client で共有する zod スキーマの一覧)
- `docs/02_detailed_design/<FID>/server-actions.md` (server action のシグネチャと振る舞い)

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

### detailed-design 固有

#### MUST
- (なし)

#### SHOULD
- npx --yes @redocly/cli lint docs/02_detailed_design/**/api-schema.yaml   # OpenAPI スニペットがあれば

#### MAY
- (なし)

### test-implementation 固有

#### MUST
- pnpm vitest --run --reporter=verbose   # 期待: 全テスト Red (Vitest 採用時)
- # pnpm jest --listTests && pnpm jest --bail   # Jest 採用時はこちらに切り替え

#### SHOULD
- (なし)

#### MAY
- (なし)

### implementation 固有

#### MUST
- pnpm typecheck   # = tsc --noEmit
- pnpm lint        # = eslint .
- pnpm format:check   # = prettier --check .
- pnpm build       # next build (型・bundle 整合)

#### SHOULD
- pnpm audit --audit-level=high
- semgrep --config=p/typescript --error .   # install: pip install semgrep

#### MAY
- jscpd src/   # install: npm install -g jscpd
- npx --yes size-limit   # bundle サイズ監視 (設定があれば)

### testing 固有

#### MUST
- pnpm vitest --run --coverage   # Vitest 採用時。Jest なら pnpm jest --coverage
- pnpm playwright test --reporter=list

#### SHOULD
- (なし)

#### MAY
- npx --yes @axe-core/cli http://localhost:3000   # ローカルで起動済みの場合のみ
- lighthouse-ci autorun   # NFR に Web Vitals 規定があれば

## REVIEW_EXTRAS (スタック由来の追加レビュー観点)
- `'use client'` が必要箇所だけに付いているか (Server Component を不必要にクライアント化していないか)
- 環境変数アクセスが `server/env.ts` 経由か
- secrets が `NEXT_PUBLIC_` でクライアント露出していないか
- API ルートにビジネスロジックが書かれていないか
- server action の入力が zod でパースされているか
- `next/image` / `next/font` を使っているか
- メタデータ (`metadata` export または `generateMetadata`) が SEO 要件を満たしているか
