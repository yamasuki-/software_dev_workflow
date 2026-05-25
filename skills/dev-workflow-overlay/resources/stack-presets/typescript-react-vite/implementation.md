# implementation — TypeScript + React + Vite rules

## ADD
- API 通信は **TanStack Query 経由のみ** (生 fetch を component 内で書かない)
  - `useXxxQuery` / `useXxxMutation` を `features/<feature>/api/` に置き、components はそれを呼ぶだけ
- 環境変数:
  - `src/env.ts` (zod でパース) を経由のみ
  - `import.meta.env.X` を直接読まない
  - 機密はクライアントに持ち込まない (SPA なので全て公開と心得る)
- 状態管理:
  - サーバ状態 → TanStack Query (キャッシュとして使う)
  - グローバル UI 状態 → Zustand (`store/`)
  - ローカル状態 → useState / useReducer
  - URL に置けるもの (filter, page) は URL クエリパラメータ
- React のベストプラクティス:
  - useEffect で fetch しない (TanStack Query を使う)
  - state の derived value は計算で出す (useState で保持しない)
  - `useCallback` / `useMemo` は **計測した上で** 使う (盲目的最適化禁止)
  - `key` に index を使わない (一意な ID を使う)
- Error Boundary を route / suspense / feature 境界に配置
  - `react-error-boundary` の `<ErrorBoundary fallback={...} onError={...}>`
- フォーム:
  - react-hook-form + zod
  - controlled / uncontrolled を混在させない (1 form 内で統一)
- スタイリング:
  - Tailwind ユーティリティを基本
  - `cn(...)` + cva で variants 整理
- アクセシビリティ:
  - semantic HTML を優先 (`<button>` / `<a>` / `<input>` を div で代用しない)
  - `aria-*` / `role` を必要箇所に
  - キーボード操作 (Tab / Enter / Esc) が動作すること
- 型安全:
  - `any` 禁止
  - `as` の濫用禁止 (zod parse / type guard / satisfies を使う)

## OVERRIDE
- ベース「コード生成時に最小実装で Green を目指す」→ Vite では zod スキーマ / TanStack Query hook は test-implementation 段階で定義済みの前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は src/ に出力)

## REVIEW_EXTRAS
- TanStack Query 以外の fetch が component に書かれていないか
- `import.meta.env` 直接アクセスがないか
- useEffect でデータ取得していないか
- `key` に index を使っていないか
- semantic HTML が使われているか (button を div で代用していないか)
- 主要操作がキーボードで完結するか
- `any` / `as` の濫用がないか
- バンドルサイズが許容内か (`vite-bundle-visualizer` 等)
- アクセシビリティテスト (jest-axe) が pass か
