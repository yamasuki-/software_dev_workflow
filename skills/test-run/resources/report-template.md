# {{phase}} — {{mode}} 確認 (test-run)

実行日時: {{executed_at}}
対象機能: {{target_fid}}
モード: {{mode}}   (red = 全 Fail 期待 / green = 全 Pass 期待)
プロジェクトルート: {{project_root}}
実行環境: {{os}} / {{runtime_versions}}

## サマリ

| 層           | 実行 | pass | fail | skip | xfail | 判定         |
|--------------|------|------|------|------|-------|--------------|
| unit         | {{unit.total}} | {{unit.pass}} | {{unit.fail}} | {{unit.skip}} | {{unit.xfail}} | {{unit.verdict}} |
| integration  | {{integration.total}} | {{integration.pass}} | {{integration.fail}} | {{integration.skip}} | {{integration.xfail}} | {{integration.verdict}} |
| e2e          | {{e2e.total}} | {{e2e.pass}} | {{e2e.fail}} | {{e2e.skip}} | {{e2e.xfail}} | {{e2e.verdict}} |
| **合計**     | {{total.total}} | {{total.pass}} | {{total.fail}} | {{total.skip}} | {{total.xfail}} | **{{verdict}}** |

期待: {{expected_text}}
実際: {{observed_text}}

## 各層の実行コマンドと出力

### unit

- コマンド: `{{unit.command}}`
- exit code: {{unit.exit_code}}
- 実行時間: {{unit.duration_sec}}s
- 出力 (先頭 100 行):

```
{{unit.output_snippet}}
```

### integration

- コマンド: `{{integration.command}}`
- exit code: {{integration.exit_code}}
- 実行時間: {{integration.duration_sec}}s
- 出力 (先頭 100 行):

```
{{integration.output_snippet}}
```

### e2e

- コマンド: `{{e2e.command}}`
- exit code: {{e2e.exit_code}}
- 実行時間: {{e2e.duration_sec}}s
- 出力 (先頭 100 行):

```
{{e2e.output_snippet}}
```

## skip / xfail 詳細

| テストID | layer | 理由 |
|---|---|---|
{{#each skipped_tests}}
| {{test_id}} | {{layer}} | {{reason}} |
{{/each}}

## 不一致 (期待と異なる結果) — verdict=FAIL の根拠

{{#if mismatches}}
mode={{mode}} で {{mismatch_description}}:

| テスト | 層 | 期待 | 実際 |
|---|---|---|---|
{{#each mismatches}}
| {{test}} | {{layer}} | {{expected}} | {{actual}} |
{{/each}}
{{else}}
- (なし — verdict=PASS)
{{/if}}

## 後続スキルへの引き渡し情報

- 本レポートは **後続の auto-check / *-review スキル** が Read する
- mode=red で verdict=PASS → test-implementation-review に進む
- mode=green で verdict=PASS → implementation の auto-check (テスト以外の MUST) → implementation-review に進む
- verdict=FAIL → オーケストレータが該当フェーズに差し戻し
- raw log: `{{log_path}}`
