# detailed-design — TypeScript + React + Vite rules

## ADD
- 機能 (FID) ごとに `src/features/<feature>/` を切り、配下に components / hooks / api / schemas を配置
- 公開 API は `features/<feature>/index.ts` (barrel) でのみ export し、内部実装を隠蔽
- ルーティングは `src/routes/` に集約し、route 定義を一覧化
  - data router を使う場合は loader / action / errorElement を route 定義に明示
- データ取得は **TanStack Query hook** に統一
  - `useXxxQuery` / `useXxxMutation` を `features/<feature>/api/` に置く
  - queryKey は `['feature', 'resource', params]` 配列形式で統一
  - staleTime / cacheTime / refetchOnWindowFocus の方針を機能ごとに明示
- フォームは react-hook-form + zod (`@hookform/resolvers/zod`) 必須
- zod スキーマは `features/<feature>/schemas/` に集約
- グローバル状態 (Zustand) は最小化、サーバ状態は TanStack Query に任せる
- 画面遷移は React Router で表現:
  - 通常遷移は route 定義一覧で十分
  - Modal / Drawer / 部分的状態遷移は Mermaid stateDiagram で記述

## OVERRIDE
- 「機能設計シーケンス図」→ Mermaid sequenceDiagram で `Browser / Component / TanStack Query / API Client / Backend` の 5 lane を必須

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/route-map.md`
  - route path / element / loader / action / errorElement の一覧
- `docs/02_detailed_design/<FID>/queries.md`
  - queryKey の体系、staleTime、無効化 (`queryClient.invalidateQueries`) の発火条件
- `docs/02_detailed_design/<FID>/zod-schemas.md`
  - 入出力スキーマ仕様の一覧。**フィールド・型・制約・エラーメッセージを表で記述し、サンプル JSON を添える (zod コードは書かない。実装フェーズで本仕様から作成)**
- `docs/02_detailed_design/<FID>/ui-design.md` に shadcn/ui のコンポーネント使用一覧、layout、a11y 要件

## REVIEW_EXTRAS
- queryKey 設計が衝突しない命名規則になっているか
- mutation 成功後の invalidate / setQueryData 戦略が明示されているか
- form の zod スキーマと API request の型が一致しているか
- Modal / Drawer 等の overlay 遷移が stateDiagram で図示されているか
- Error Boundary 配置粒度 (page / feature / suspense 境界) が設計されているか
- a11y (キーボード操作、aria-*) の要件が設計に含まれているか
