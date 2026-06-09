# unit-test-review レビュー票

| 項目 | 内容 |
|---|---|
| 対象機能 | {{FID}} |
| mode | {{per_feature \| cross}} |
| 反復回数 | {{iteration}} |
| レビュー日時 | {{reviewed_at}} |
| 検証対象 | **詳細設計** (`docs/02_detailed_design/{{FID}}/*.md`) |
| testing 実行 | `docs/04_test_results/{{FID}}/unit-test-result.md` |

## 判定結果

- **verdict**: {{layer_completed \| pending_bug_fix \| fail}}
- **result**: {{pass \| fail}}
- open_bugs (unit): {{count}} 件 — {{list}}
- next_action: {{文字列}}

## 詳細設計カバレッジ (Section A)

| 詳細設計要素 | カバーする UT-ID | 状態 |
|---|---|---|
| サブ機能 SF-001 | UT-{{FID}}-001, UT-{{FID}}-002 | covered |
| エラー E001 | UT-{{FID}}-005 | covered / fail (B003) |
| 状態遷移 T1→T2 (guard=X) | UT-{{FID}}-007 | covered |
| UI バリデーション V1 | UT-{{FID}}-010 | covered |
| DB 制約 (users.email UNIQUE) | UT-{{FID}}-012 | covered |
| ... | ... | ... |

カバレッジ漏れ:
- (なし | あれば列挙)

## 単体テスト固有品質 (Section B)

- AAA パターン適合率: {{N/M}} ({{適合しない例: UT-NNN ...}})
- 1テスト1観点違反: {{なし | UT-NNN, ... }}
- モック適切性: {{適切 | 過剰モック箇所: UT-NNN ...}}
- 命名規約逸脱: {{なし | 列挙}}

## カバレッジ実測 (Section C)

| 項目 | 目標 | 実測 | 判定 |
|---|---|---|---|
| 分岐網羅 | {{X%}} | {{Y%}} | {{達成 / 未達}} |
| 命令網羅 | {{X%}} | {{Y%}} | {{達成 / 未達}} |

## 不具合一覧 (本 layer のみ)

| bug_id | title | severity | status | 該当テスト |
|---|---|---|---|---|
| B001 | ... | medium | open | UT-{{FID}}-005 |

## 横断観点 (cross の場合のみ)

- モック対象の一貫性: ...
- 命名規約の統一: ...
- COMMON 単体テスト: ...
- 重複 bug 解析: ...

## auto-check との連動

- auto-check 結果レポート: `docs/06_reviews/{{FID}}/testing-auto-check.md`
- SHOULD warning の判定: {{accept N 件 / reject M 件}}
- skipped_missing_tools: {{list}}

## 次のアクション

- {{verdict によって決まる}}
