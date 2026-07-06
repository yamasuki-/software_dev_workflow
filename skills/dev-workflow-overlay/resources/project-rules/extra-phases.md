# Workflow Extra Phases — プロジェクト固有の追加フェーズ

> ベースワークフローのフェーズ遷移に **追加挿入** したいフェーズをここに定義する。
> dev-workflow-overlay がこのファイルを Read してフェーズ表に統合する。

## スキーマ

各追加フェーズは以下のブロックで定義する。

```
## PHASE: <id>
position: <before|after> <既存フェーズ識別子>
skill: <スキル名>
project_local: <yes|no>
gating: <blocks_next_phase_on_fail | warn_only_on_fail>
artifact_path: <相対パス (任意)>
description: <1行説明 (任意)>
```

### 既存フェーズ識別子 (position 指定で使う)

```
basic_design                  basic_design_review
detailed_design               detailed_design_review
test_design                   test_design_review
test_implementation           test_implementation_review
implementation                implementation_review
testing                       testing_review
bug_fix                       bug_fix_review
```

### gating
- `blocks_next_phase_on_fail`: 通常のレビューゲートと同じ。fail なら次に進まない
- `warn_only_on_fail`: fail でも次に進める。`decisions.md` に警告を記録

### project_local
- `yes` → `<PROJECT_ROOT>/.claude/skills/<skill>/SKILL.md` が必須
- `no`  → グローバルに同名スキルがあるか、存在しなければエラー

---

## 例 1: アクセシビリティレビューを実装後に挿入

> 注: セキュリティレビュー (`security-review`) は現在 **ベース構成の正式 Agent** (implementation-review の後段ブロッキングゲート) に昇格済みのため、ここで追加定義する必要はない。観点追加は `.dev-workflow/rules/(stack|project)/security-review.md` の `REVIEW_EXTRAS` を使う。以下は別観点を追加する例。

```
## PHASE: a11y-review
position: after security_review
skill: a11y-review
project_local: yes
gating: blocks_next_phase_on_fail
artifact_path: docs/09_a11y/<FID>/
description: 実装後にアクセシビリティ観点 (WCAG/キーボード操作/コントラスト) の専門レビューを行う
```

## 例 2: パフォーマンス計測 (警告のみ)

```
## PHASE: performance-baseline
position: after testing_review
skill: performance-baseline
project_local: yes
gating: warn_only_on_fail
artifact_path: docs/10_performance/<FID>/
description: 機能完了時のパフォーマンス基準値を記録する (劣化があれば警告のみ)
```

## 例 3: アクセシビリティチェック (UI機能のみ)

```
## PHASE: a11y-check
position: before testing
skill: a11y-check
project_local: yes
gating: blocks_next_phase_on_fail
artifact_path: docs/11_a11y_check/<FID>/
description: WCAG 2.1 AA 準拠を確認 (UIあり機能のみ)
```

---

## 追加フェーズの定義はここから

(各プロジェクトで必要な分だけ追加する。空のままでも問題ない。)
