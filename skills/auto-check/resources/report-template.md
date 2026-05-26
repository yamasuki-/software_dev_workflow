# {{phase}} — auto-check 結果

実行日時: {{executed_at}}
対象モード: {{mode}}   (per_feature | cross)
対象機能: {{target_fids}}   (per_feature の場合は単一 FID、cross の場合は "ALL")
プロジェクトルート: {{project_root}}
実行環境: {{os}} / {{runtime_versions}}

## サマリ

| 階層   | 実行 | pass | fail | skipped (missing) |
|--------|------|------|------|-------------------|
| MUST   | {{must.total}}   | {{must.pass}}   | {{must.fail}}   | {{must.skipped}}   |
| SHOULD | {{should.total}} | {{should.pass}} | {{should.fail}} | {{should.skipped}} |
| MAY    | {{may.total}}    | {{may.pass}}    | {{may.fail}}    | {{may.skipped}}    |

**判定: {{verdict}}**   (PASS | FAIL (MUST 失敗あり))

ゲート挙動:
- PASS の場合: 後段の {{phase}}-review (per_feature → cross) に進む
- FAIL の場合: {{phase}} フェーズに差し戻し。詳細は下記 MUST 詳細を参照

## MUST 詳細

{{#each must_results}}
### {{name}}
- コマンド: `{{command}}`
- exit code: {{exit_code}}
- 実行時間: {{duration_sec}}s
- 出力 (先頭 50 行):

```
{{output_snippet}}
```

{{/each}}

## SHOULD 詳細

{{#each should_results}}
### {{name}}
- コマンド: `{{command}}`
- exit code: {{exit_code}}
- 出力 (先頭 50 行):

```
{{output_snippet}}
```

{{/each}}

## MAY 詳細 (info のみ)

{{#each may_results}}
### {{name}}
- コマンド: `{{command}}`
- exit code: {{exit_code}}
- 出力 (先頭 20 行):

```
{{output_snippet}}
```

{{/each}}

## skipped (tool not installed)

{{#each skipped_tools}}
- {{name}} ({{tier}}): install hint = `{{install_hint}}`
{{/each}}

## 後続レビューへの引き渡し情報

- MUST に fail があった場合、本レポートを基に {{phase}} フェーズへ差し戻し
- SHOULD warning は LLM レビューが判断 (個別に accept する場合は `decisions.md` に記録)
- MAY info は参考情報
- skipped は環境整備の課題として認識し、CI 側で必ず実行できることを担保
