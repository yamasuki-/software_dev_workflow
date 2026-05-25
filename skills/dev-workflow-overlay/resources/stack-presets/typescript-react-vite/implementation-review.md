# implementation-review — TypeScript + React + Vite rules

## REVIEW_EXTRAS

> per_feature モードと cross モードの両方の追加観点を含む。dev-workflow-overlay が mode に応じて拾う。

### 静的解析
- [ ] `pnpm typecheck` (`tsc --noEmit`) が 0 件
- [ ] `pnpm lint` が 0 件
- [ ] `pnpm format:check` が 0 件
- [ ] `pnpm build` が成功

### React パターン
- [ ] API 通信が TanStack Query 経由 (生 fetch を component に書いていない)
- [ ] useEffect でデータ取得していない
- [ ] state の derived value を useState で保持していない
- [ ] `key` に index を使っていない
- [ ] `useCallback` / `useMemo` を盲目的に使っていない

### 型安全
- [ ] `any` を新規導入していない
- [ ] `as` キャストの濫用がない (zod parse / type guard / `satisfies` 優先)
- [ ] zod スキーマと TanStack Query の型推論が整合している

### 環境変数 / セキュリティ
- [ ] `import.meta.env` 直接アクセスがない (`env.ts` 経由)
- [ ] 機密情報を SPA に持ち込んでいない
- [ ] CSP / セキュリティヘッダ (静的ホスティング側の設定が docs に)
- [ ] XSS: `dangerouslySetInnerHTML` の使用箇所が妥当

### アクセシビリティ
- [ ] semantic HTML が使われている (button / a / input / label)
- [ ] 主要操作がキーボードで完結
- [ ] aria-* が必要箇所に
- [ ] jest-axe が pass

### パフォーマンス
- [ ] バンドルサイズが許容内 (`vite-bundle-visualizer` / size-limit)
- [ ] code splitting (React.lazy / dynamic import) が必要箇所で使われているか
- [ ] 画像最適化 (適切な format / size / lazy)

### TanStack Query
- [ ] queryKey が体系的 (衝突しない)
- [ ] mutation 後の invalidate / setQueryData が適切
- [ ] retry / staleTime / cacheTime が機能要件に合致

### Error Handling
- [ ] Error Boundary が route / feature 境界に配置
- [ ] エラー UI が user-friendly
- [ ] Sentry 等への送信 (本番のみ)

### 横断 (cross) モード追加観点
- [ ] 同等の zod スキーマが複数 feature で別名定義されていないか
- [ ] 同等の UI コンポーネントが features/ 間で重複していないか (`components/` 抽出)
- [ ] 同等の TanStack Query hook が複数 feature で重複していないか
- [ ] queryKey 命名規則が全 features で揃っているか
- [ ] env スキーマが一箇所に集約されているか
