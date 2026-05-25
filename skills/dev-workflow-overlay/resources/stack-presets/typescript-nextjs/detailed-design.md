# detailed-design — TypeScript + Next.js rules

## ADD
- 機能 (FID) ごとに `src/features/<feature>/` を切り、配下に components / hooks / server / schemas を配置
- ページ / レイアウトは `src/app/` の route segment に置き、各 segment の説明は `route-map.md` に列挙
- データ取得は **Server Component** か **server actions** を第一選択
  - SSR ページなら RSC 内で fetch (キャッシュ戦略を明示: force-cache / no-store / revalidate)
  - mutation は server action で
- zod スキーマは `features/<feature>/schemas/` に集約し、server / client 双方で型・バリデーションを共有
- API ルート (`app/api/.../route.ts`) を作る場合は **理由 (外部からの公開 / webhook など)** を `route-map.md` に明記
- フォームは react-hook-form + zod (`@hookform/resolvers/zod`) を必須パターンとする
- 認可は middleware + 各 server action / API ルートで二重チェック (middleware だけに依存しない)
- 状態管理は基本不要 (RSC + server actions)。必要時のみ Zustand を `features/<feature>/store.ts` に限定使用

## OVERRIDE
- 「機能設計シーケンス図」→ Mermaid sequenceDiagram で `Browser / Middleware / RSC / Server Action / Service / DB` の lane を必須
- 「画面遷移図必須」→ route segment 構造で表現される場合は省略可。modal / parallel / intercepting routes を使う場合のみ Mermaid stateDiagram で記述

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/route-map.md`
  - 該当機能で追加 / 変更する route segment、layout / page / loading / error の一覧、SSR/ISR/SSG の方針、cache 戦略
- `docs/02_detailed_design/<FID>/zod-schemas.md`
  - 入出力 zod スキーマ一覧 (form schema, action input/output schema, db row schema)
- `docs/02_detailed_design/<FID>/server-actions.md`
  - server action の名前 / 入力スキーマ / 戻り型 (Result 型) / 認可要件
- `docs/02_detailed_design/<FID>/ui-design.md` に shadcn/ui の使用コンポーネント一覧と layout を記載

## REVIEW_EXTRAS
- Server Component / Client Component の境界が `'use client'` の最小範囲で表現されているか
- データ取得の cache 戦略 (force-cache / no-store / revalidate) が明示されているか
- フォームに zod + react-hook-form が適用されているか
- 認可が middleware + server action / API ルートで二重チェックされているか
- modal / parallel / intercepting routes を使う場合、状態遷移が stateDiagram で図示されているか
- メタデータ (SEO, OG image) の設計が含まれているか
