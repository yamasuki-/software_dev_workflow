# e2e-test-review レビュー票

| 項目 | 内容 |
|---|---|
| 対象機能 | {{FID}} |
| mode | {{per_feature \| cross}} |
| 反復回数 | {{iteration}} |
| レビュー日時 | {{reviewed_at}} |
| 検証対象 | **要件定義書** (`docs/requirements/requirements.md`) |
| testing 実行 | `docs/04_test_results/{{FID}}/e2e-test-result.md` |

## 判定結果

- **verdict**: {{layer_completed \| pending_bug_fix \| fail}}
- **result**: {{pass \| fail}}
- open_bugs (e2e): {{count}} 件 — {{list}}
- next_action: {{文字列}}
- **testing フェーズ全体完了可否**: {{可 (全 3 layer 完了) | 不可 (理由: ...)}}

## 要件カバレッジ (Section A — 100% 必須)

| 要件 ID (USDM `R-###` / UC) | カバーする E2E シナリオ ID | 状態 | 受入条件転記 |
|---|---|---|---|
| R-001 (新規登録) | E2E-{{FID}}-001 | covered, pass | あり |
| R-002 (ログイン) | E2E-{{FID}}-002 | covered, fail (B007) | あり |
| R-003 (パスワード変更) | E2E-{{FID}}-003 | covered, pass | あり |
| ... | ... | ... | ... |

**要件カバレッジ**: {{N/M}} ({{100%? Yes/No}})

カバレッジ漏れ (1 要件 = 0 E2E):
- (なし | あれば列挙 → これがあれば verdict=fail)

業務シナリオ (複数機能またぎ):
- {{シナリオ名 → E2E-NNN}}

## E2E 固有品質 (Section B)

- 自動化された E2E: {{Yes (Playwright/Maestro/Detox) / No (手動のみ)}}
  - trace / screenshot 設定: {{あり / なし}}
- 手動 E2E: {{なし / あり (手順書: tests/e2e/<FID>/manual/...)}}
  - 手順書の再現性: {{OK / 不足: ...}}
- 環境依存性: {{本番相当 / staging / ローカル}}
- テストデータ初期化: {{明示 / 不足}}
- flaky テスト: {{なし / あり: E2E-NNN ...}}

## 前層完了確認 (Section E)

- `phases.testing.layers.unit.status`: {{completed}}, `open_bugs[]`: {{[]}}
- `phases.testing.layers.integration.status`: {{completed}}, `open_bugs[]`: {{[]}}
- 両層完了確認: {{OK / 規律違反}}

## 不具合一覧 (本 layer のみ)

| bug_id | title | severity | status | 該当シナリオ |
|---|---|---|---|---|
| B007 | ... | high | open | E2E-{{FID}}-002 |

## 横断観点 (cross の場合のみ)

- 全機能横断の要件カバレッジ (= プロジェクト全体の要件): {{100% / 不足: ...}}
- 業務シナリオの整合: ...
- COMMON 関連 E2E: ...
- 重複 bug 解析: ...

## auto-check との連動

- auto-check 結果レポート: `docs/06_reviews/{{FID}}/testing-auto-check.md`
- SHOULD warning の判定: {{accept N 件 / reject M 件}}

## testing フェーズ完了の推奨

- 全 3 layer status=completed: {{Yes / No (理由: ...)}}
- 全 3 layer open_bugs=[]: {{Yes / No}}
- `phases.testing.status = "completed"` 推奨: {{Yes / No}}

## 次のアクション

- {{verdict によって決まる}}
