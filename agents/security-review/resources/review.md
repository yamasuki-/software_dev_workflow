# セキュリティレビュー — {{対象 (FID または "全体")}} ({{mode: per_feature / cross}})

| 項目 | 内容 |
| ---- | ---- |
| レビュー対象フェーズ | implementation (security) |
| 対象機能ID | {{FID または "全体"}} |
| mode | {{per_feature / cross}} |
| レビュー実施日時 |  |
| 準拠基準 | OWASP Top 10 / OWASP LLM Top 10 (該当時) / 秘密情報・設定 / ビジネスロジック・DoS / 依存関係 / IaC・CI / non-functional セキュリティ要件 |
| **総合判定** | **pass** / **fail** |

## 1. インプット (参照した成果物)

| 種別 | パス |
| ---- | ---- |
| 非機能要件 | docs/01_basic_design/non-functional.md |
| 詳細設計 |  |
| 依存定義 |  |
| auto-check 結果 |  |

## 2. レビュー対象 (プロダクトコード)

| 種別 | パス |
| ---- | ---- |
|      |      |

## 3. チェックリスト

> per_feature は A〜G、cross は H〜K を埋める (security-review.md のチェックリスト参照)。
> G (LLM) / K (インフラ設定) は対象が存在しない場合「該当なし」と記入。
> overlay (`rules/(stack|project)/security-review.md`) の REVIEW_EXTRAS がある場合は表の末尾に行を追加して判定する。

| # | 観点 | 結果 (OK/NG/該当なし) | 備考 |
| - | ---- | --------------------- | ---- |
| A | OWASP Top 10 (アクセス制御/暗号化/インジェクション 等) |  |  |
| B | 入力検証・出力エンコーディング (CSRF/SSTI/XXE/オープンリダイレクト/マスアサインメント含む) |  |  |
| C | 秘密情報・設定の安全性 (セキュリティヘッダ含む) |  |  |
| D | non-functional セキュリティ要件との整合 |  |  |
| E | detailed-design との整合 (セキュリティ観点) |  |  |
| F | ビジネスロジック悪用・DoS 耐性 |  |  |
| G | LLM / 生成 AI 機能 (OWASP LLM Top 10) |  |  |
| H | 依存関係の脆弱性 (cross) |  |  |
| I | 認証・認可・秘密管理の横断一貫性 (cross) |  |  |
| J | 攻撃対象領域の全体評価 (cross) |  |  |
| K | インフラ・パイプライン設定 (cross) |  |  |

## 4. 検出された脆弱性・所見

| 所見ID | 重大度 (Critical/High/Medium/Low/Info) | 分類 (OWASP ID / LLM ID / 秘密情報 / 依存 / 設定 / 設計 / ロジック / インフラ) | 内容 | 該当ファイル:箇所 | 再現条件 | 推奨対応 |
| ------ | -------------------------------------- | ----------------------------------------------- | ---- | ----------------- | -------- | -------- |
| S-01   |                                        |                                                 |      |                   |          |          |

> 詳細な再現条件・PoC・修正方針は `docs/08_security/<FID>/findings.md` を参照。

## 5. 結論と推奨アクション

- 結果: **pass** / **fail**
- pass の場合: 次フェーズ (testing) に進める
- fail の場合 (Critical/High が 1 件以上、または未受容の Medium):
  - 戻すフェーズ: implementation / detailed-design / basic-design(non-functional)
  - 修正してほしい所見ID一覧:
  - 緊急度:
- 受容した Medium (理由は decisions.md に記録):

## 6. 補足
- 補償的コントロール、CI でのスキャン導入推奨、今後の課題など。
