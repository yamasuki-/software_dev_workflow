# detailed-design — Python + Django rules

## ADD
- 機能を **Django app 単位** で分割する (1 機能 = 1 app または 1 app 内の subdomain)
- ビジネスロジックは `services.py` に関数として実装する (fat-model / fat-view を避ける)
  - Service 関数のシグネチャは `def <verb>_<noun>(*, ...) -> ResultDTO:` 形式 (キーワード引数必須)
- 入出力 (API 境界) は **DRF Serializer** で定義する
  - Request serializer: `<Action><Resource>RequestSerializer`
  - Response serializer: `<Resource>Serializer` または `<Action><Resource>ResponseSerializer`
- View 層は **ViewSet** を基本とし、ルーティングは DRF Router で行う
  - 1 resource = 1 ViewSet
  - 標準 CRUD で表現できないものは `@action` デコレータ
- 認可はカスタム `permission_classes` を明示 (`IsAuthenticated` だけで済ませない)
- DB モデルは `models.py` に定義し、主要関連は Mermaid erDiagram でも併記する
- マイグレーションは設計時にも考慮し、データ移行が必要な場合は `RunPython` 用の関数設計を含める

## OVERRIDE
- 「機能設計シーケンス図にレイヤを記載」→ Mermaid sequenceDiagram で `Client / View(ViewSet) / Service / Model(ORM) / DB` の 5 lane を必須とする
- 「DB 設計を ER 図で記述」→ 設計の正は **Mermaid erDiagram (主要関連) + カラム定義表** (型 / null / PK / FK / index / 制約)。Django Model コードは **実装フェーズで本設計から作成** する (設計書にコードは書かない)

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/02_detailed_design/<FID>/api-schema.yaml`
  - 該当機能のエンドポイントだけ drf-spectacular で出力したスニペット
- `docs/02_detailed_design/<FID>/serializers.md`
  - 主要 serializer の項目説明、バリデーションルール、サンプル JSON。**表形式で記述 (Serializer コードは書かない。実装フェーズで本仕様から作成)**
- `docs/02_detailed_design/COMMON/permissions.md`
  - 共通 permission クラスの一覧と適用ルール

## REVIEW_EXTRAS
- ViewSet ごとに `permission_classes` / `authentication_classes` が明示されているか
- ビジネスロジックが Model / View / Serializer に漏れていないか (Service に集約されているか)
- Serializer の `read_only_fields` / `write_only_fields` が適切か
- N+1 を避ける `select_related` / `prefetch_related` がクエリ設計に含まれているか
- マイグレーション設計に **データ移行戦略** (RunPython / backfill タイミング) があるか
