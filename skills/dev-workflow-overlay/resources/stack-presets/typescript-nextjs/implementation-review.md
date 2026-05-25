# implementation-review — TypeScript + Next.js rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `pnpm typecheck` (`tsc --noEmit`) が 0 件
- [ ] `pnpm lint` (ESLint) が 0 件
- [ ] `pnpm format:check` が 0 件
- [ ] `pnpm build` が成功

### App Router / Server / Client
- [ ] App Router 構造で書かれている (Pages Router の混在なし)
- [ ] `'use client'` が必要箇所だけ
- [ ] データ取得が RSC / server action 中心
- [ ] API ルートが薄く、ロジックは services/ に分離

### 型安全
- [ ] `any` を新規導入していない
- [ ] `as` キャストの濫用がない (zod parse / type guard 優先)
- [ ] zod スキーマが server / client で適切に共有されている

### 環境変数 / セキュリティ
- [ ] `process.env.X` の直接アクセスがない (`server/env.ts` 経由)
- [ ] `NEXT_PUBLIC_` 接頭辞で secrets を露出していない
- [ ] server action / API ルート冒頭で認可チェック
- [ ] CSP / セキュリティヘッダ設定 (next.config.js の headers)
- [ ] XSS: `dangerouslySetInnerHTML` の使用箇所が妥当か

### パフォーマンス
- [ ] cache 戦略 (force-cache / no-store / revalidate) が明示
- [ ] `next/image` / `next/font` を使用
- [ ] バンドルサイズが許容内 (`@next/bundle-analyzer` で確認)
- [ ] dynamic import が必要箇所で使われているか
- [ ] React Server Component のシリアライズ可能性に違反していないか

### フォーム / バリデーション
- [ ] react-hook-form + zod パターン
- [ ] form の zod スキーマと server action の zod スキーマが共有されているか

### SEO / アクセシビリティ
- [ ] `metadata` export または `generateMetadata` が定義
- [ ] 主要ページで semantic HTML / role / aria-* が適切

### 横断 (cross) モード追加観点
- [ ] 同等の zod スキーマが複数 feature で別名定義されていないか (共通化)
- [ ] 同等の UI コンポーネントが features/ 間で重複していないか (`components/` への抽出)
- [ ] `server/services/` の関数が features/ 間で再利用可能な抽象になっているか
- [ ] env スキーマが一箇所に集約されているか
- [ ] middleware / layout / loading / error の階層が一貫しているか
