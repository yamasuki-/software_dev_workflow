# integration-test-review レビュー票

| 項目 | 内容 |
|---|---|
| 対象機能 | {{FID}} |
| mode | {{per_feature \| cross}} |
| 反復回数 | {{iteration}} |
| レビュー日時 | {{reviewed_at}} |
| 検証対象 | **基本設計** (`docs/01_basic_design/*.md`) |
| testing 実行 | `docs/04_test_results/{{FID}}/integration-test-result.md` |

## 判定結果

- **verdict**: {{layer_completed \| pending_bug_fix \| fail}}
- **result**: {{pass \| fail}}
- open_bugs (integration): {{count}} 件 — {{list}}
- next_action: {{文字列}}

## 基本設計カバレッジ (Section A)

| 基本設計要素 | カバーする IT-ID | 状態 |
|---|---|---|
| アーキ I/F (API ↔ Service) | IT-{{FID}}-001 | covered |
| 機能間依存 (F002 入力 = F001 出力) | IT-{{FID}}-005 | covered |
| データフロー D1 (外部 SaaS → DB) | IT-{{FID}}-007 | covered |
| 非機能 (応答時間 < 200ms) | IT-{{FID}}-010 | covered (実測 180ms) |
| トランザクション境界 (rollback on error) | IT-{{FID}}-012 | covered |
| ... | ... | ... |

カバレッジ漏れ:
- (なし | あれば列挙)

## 結合テスト固有品質 (Section B)

- 実 DB 使用: {{Yes / 一部モック箇所あり: IT-NNN}}
- 外部システム連携: {{実物 / sandbox / モック箇所: ...}}
- N+1 検出: {{含まれる: IT-NNN / 含まれない}}
- トランザクション境界テスト: {{あり / なし}}
- flaky テスト: {{なし / IT-NNN ...}}
- テストデータ後始末: {{transactional rollback / truncate / なし}}

## 前層 (unit) 完了確認 (Section F)

- `phases.testing.layers.unit.status`: {{completed}}
- `phases.testing.layers.unit.open_bugs[]`: {{[]}}
- 前層完了確認: {{OK / 規律違反}}

## 不具合一覧 (本 layer のみ)

| bug_id | title | severity | status | 該当テスト |
|---|---|---|---|---|
| B005 | ... | high | open | IT-{{FID}}-007 |

## 横断観点 (cross の場合のみ)

- DB / 外部システム使用の一貫性: ...
- 機能間連携シナリオの網羅: ...
- COMMON 結合テスト: ...
- 重複 bug 解析: ...

## auto-check との連動

- auto-check 結果レポート: `docs/06_reviews/{{FID}}/testing-auto-check.md`
- SHOULD warning の判定: {{accept N 件 / reject M 件}}

## 次のアクション

- {{verdict によって決まる}}
