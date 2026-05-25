# implementation — TypeScript + Next.js rules

## ADD
- Server Component を既定とし、`'use client'` は必要時のみ
  - 必要時 = 状態 / イベントハンドラ / Browser API / クライアント側ライブラリの使用
- データ取得:
  - RSC 内で fetch (cache 戦略を明示: `{ cache: 'force-cache' | 'no-store', next: { revalidate: n } }`)
  - mutation は server action のみ (`'use server'`)
  - クライアント側で必要なら React Query (用途を限定)
- server actions:
  - 入力は **必ず zod でパース** (`schema.parse(input)`) してから処理
  - 戻り型は Result 型 (`{ ok: true, data } | { ok: false, error }`) で統一
  - 認可チェックを冒頭で実施 (middleware だけに頼らない)
- API ルート (`route.ts`):
  - 薄く保ち、ロジックは `server/services/` に集約
  - レスポンス: `NextResponse.json(...)` で型を維持
- 環境変数:
  - `src/server/env.ts` (zod でパース) を経由のみ
  - クライアント露出値は `NEXT_PUBLIC_` プレフィックス + 別 env スキーマ
  - `process.env.X` を直接読まない
- スタイリング:
  - Tailwind ユーティリティを基本
  - 複雑な再利用は `cn(...)` ヘルパ + variants (cva)
- フォーム:
  - react-hook-form + zod (`@hookform/resolvers/zod`)
  - server action と form の zod スキーマを共有
- 画像 / フォント:
  - `next/image` / `next/font` を使用 (生 `<img>` / `<link rel="font">` 禁止)
- メタデータ:
  - 各 page で `metadata` export または `generateMetadata` を定義 (SEO)
- ログ:
  - server 側のみ pino (`server/logger.ts`)
  - クライアントで `console.log` を残さない (Sentry / 計測サービスに送る)
- 型安全:
  - `any` 禁止 (eslint で error)
  - `as` キャストを濫用しない (zod parse か type guard を優先)

## OVERRIDE
- ベース「コード生成時に最小実装で Green を目指す」→ Next.js では zod スキーマ / Prisma スキーマが test-implementation 段階で定義済みの前提

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- なし (実装は src/ 配下)

## REVIEW_EXTRAS
- `'use client'` が必要箇所だけにあるか (Server Component の機会を逃していないか)
- 環境変数アクセスが `server/env.ts` 経由か
- secrets が `NEXT_PUBLIC_` 接頭辞でクライアント露出していないか
- server action の入力が zod でパースされているか
- API ルートが薄いか (ビジネスロジックを services/ に逃がしているか)
- cache 戦略が明示されているか (RSC fetch オプション)
- `any` / `as` の濫用がないか
- `next/image` / `next/font` が使われているか
- メタデータ export があるか
- 認可が server action / API ルート冒頭でチェックされているか
