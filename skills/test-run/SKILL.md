---
name: test-run
description: テストランナーを実行し、結果ドキュメントを `docs/04_test_results/<FID>/` に保存する単一責務スキル。test-implementation 完了直後の Red 確認 (mode=red) と implementation 完了直後の Green 確認 (mode=green) の両方で使われる。dev-workflow オーケストレータから自動で spawn される。test-implementation-review / implementation-review はこの結果を読むだけで、自分ではテストを実行しない。
---

# test-run — テスト実行と結果記録

## 役割

実装系フェーズ完了直後に **テストランナーを実行する単一責務スキル**。

- **コードを書かない**: 既存のテストコード/プロダクトコードを実行するだけ
- **判定は両モード:**
  - `mode=red`: 全テストが必ず **Fail** することを確認 (test-implementation 後)
  - `mode=green`: 全テストが必ず **Pass** することを確認 (implementation 後)
- 期待と異なる結果なら verdict=FAIL を返し、オーケストレータが該当フェーズに差し戻す
- 結果ドキュメントを `docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md` に出力

この分離により、後続の **`test-implementation-review` / `implementation-review` は自分でテスト実行しなくてよくなる** (本スキルが出した結果を Read するだけ)。

## サブエージェント実行前提

- `dev-workflow` から **対象機能の test-implementation または implementation 完了直後に自動 spawn** される。
- スコープは **1機能 (`<FID>`)**。
- 戻り値: `summary` / `verdict` (PASS|FAIL) / `executed` / `passed` / `failed` / `report_path` / `updated_files` / `next_action`。

## 入出力

### 入力 (ブリーフ)

```
phase:            test-implementation | implementation
mode:             red | green
target_fid:       <FID>
project_root:     <PROJECT_ROOT 絶対パス>
test_command:     <ランナーコマンド (任意。未指定なら stack-config.md から読む)>
test_layers:      [unit, integration, e2e]   (実行する層を指定)
```

### 出力

| 項目 | 配置 / 戻り値 |
|---|---|
| テスト実行レポート | `<PROJECT_ROOT>/docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md` |
| カバレッジ・実行ログ | `<PROJECT_ROOT>/docs/04_test_results/<FID>/<phase>-<mode>-run.log` (raw stdout/stderr) |
| 状態ファイル更新 | `.dev-workflow/features/<FID>/status.json` の `phases.<phase>.test_run` |
| 戻り値 | `verdict` (PASS|FAIL), `executed`, `passed`, `failed`, `expected_state` (red|green), `report_path` |

## テスト実行コマンドの解決順

1. ブリーフの `test_command` で明示されていればそれを使う
2. `<PROJECT_ROOT>/.dev-workflow/rules/project/stack-config.md` の **「テスト実行コマンド」** セクション
3. `<PROJECT_ROOT>/.dev-workflow/rules/stack/stack-config.md` の **「テスト実行コマンド」** セクション
4. なければエラーで停止 (オーケストレータにエスカレーション)

`stack-config.md` で宣言する想定フォーマット:

```markdown
## テスト実行コマンド (test-run)

### 単体 (unit)
- command: uv run pytest tests/unit/<FID>/ -v
- coverage: uv run pytest tests/unit/<FID>/ --cov=src --cov-report=term

### 結合 (integration)
- command: uv run pytest tests/integration/<FID>/ -v

### E2E (e2e)
- command: uv run pytest tests/e2e/<FID>/ -v
```

`<FID>` プレースホルダは test-run が自動で置換する。

## 判定ロジック

| mode | 期待 | verdict 条件 |
|---|---|---|
| `red` | 全テスト Fail (= passed = 0 かつ failed > 0) | failed > 0 かつ passed = 0 → PASS。それ以外 → FAIL |
| `green` | 全テスト Pass (= failed = 0 かつ passed > 0) | failed = 0 かつ passed > 0 → PASS。それ以外 → FAIL |

`skipped` / `xfail` テストは結果から除外して判定する (理由が記録されていれば許容)。理由なしの skip があれば warning として記録するが verdict は変えない。

## 実行手順

### Step 1: ルール読み込み

1. `<PROJECT_ROOT>/.dev-workflow/rules/stack/stack-config.md` および `project/stack-config.md` の「テスト実行コマンド」セクションを Read
2. 入力の `test_layers` で指定された層のコマンドを抽出
3. `<FID>` プレースホルダを実 FID に置換

### Step 2: テスト実行

1. 各層 (unit → integration → e2e の順) で `Bash` ツールでコマンドを実行
2. stdout / stderr を raw ログとして保存
3. パーサで pass/fail/skip 件数を集計 (pytest なら `=== N passed, M failed ===` 等)
4. **重要**: コード本体・テストコードを **書き換えない** (autofix 系コマンドは禁止)

### Step 3: 判定

mode=red / green ごとに verdict を決定。期待と異なる場合は FAIL。

### Step 4: レポート生成

`docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md` に Markdown レポートを出力:

```markdown
# <phase> — <mode> 確認 (test-run)

実行日時: <ISO 8601>
対象機能: <FID>
モード: <red|green>
プロジェクトルート: <PROJECT_ROOT>

## サマリ

| 層 | 実行 | pass | fail | skip | xfail | 判定 |
|---|---|---|---|---|---|---|
| unit | N | N | N | N | N | PASS / FAIL |
| integration | N | N | N | N | N | PASS / FAIL |
| e2e | N | N | N | N | N | PASS / FAIL |
| **合計** | N | N | N | N | N | **<verdict>** |

期待: <red = 全 fail / green = 全 pass>
実際: <観測された状態>

## 各層の実行コマンドと出力

### unit
- コマンド: `<実行したコマンド>`
- exit code: <code>
- 実行時間: <sec>
- 出力 (先頭 100 行):
  ```
  ...
  ```

### integration
...

### e2e
...

## skip / xfail 詳細

| テストID | layer | 理由 |
|---|---|---|
| ... | ... | ... |

## 不一致 (期待と異なる結果)

mode=red で pass したテスト、または mode=green で fail したテスト:

| テスト | 層 | 期待 | 実際 |
|---|---|---|---|
| ... | ... | ... | ... |

これらが verdict=FAIL の根拠。
```

### Step 5: 状態ファイル更新

`.dev-workflow/features/<FID>/status.json`:

```json
{
  "phases": {
    "<phase>": {
      "test_run": {
        "mode": "red|green",
        "executed_at": "<ISO 8601>",
        "verdict": "PASS|FAIL",
        "executed": <int>,
        "passed": <int>,
        "failed": <int>,
        "skipped": <int>,
        "xfail": <int>,
        "report_path": "docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md",
        "log_path": "docs/04_test_results/<FID>/<phase>-<mode>-run.log"
      }
    }
  }
}
```

### Step 6: 戻り値サマリ

```
test-run 完了
phase: <phase>
mode: <red|green>
target: <FID>

executed: N
passed: N
failed: N
expected: <全 red / 全 green>

verdict: PASS|FAIL
report: <絶対パス>

次のアクション (オーケストレータが判断):
- PASS → 後続の auto-check → LLM レビュー に進む
- FAIL → 該当フェーズに差し戻し (mode=red なら test-implementation、mode=green なら implementation)
```

## 注意事項

- **コード書き換え禁止**: テスト/プロダクトコードを修正してはいけない。autofix 系コマンド (`ruff format --fix`, `prettier --write` 等) は使わない
- **テスト追加禁止**: 本スキルは「実行のみ」。新規テストを書く必要があれば test-implementation か bug-fix に戻る
- **タイムアウト**: 各層 30 分、全体 1 時間でハードリミット
- **flaky 検出**: 同じテストが run ごとに違う結果を返すと疑われる場合、レポートに warning として記録 (verdict は変えない)
- **secrets を出力に含めない**: 環境変数値が含まれる可能性がある場合、ログ貼付前にマスクする

## auto-check との関係

auto-check が同じテストランナーを別目的で実行することもある (例: stack-config.md の testing フェーズで `pytest --cov-fail-under=80`)。test-run と auto-check の責務は分離する:

| スキル | 目的 | フェーズ |
|---|---|---|
| **test-run** | テスト結果の **状態確認** (Red であること / Green であること) | test-implementation / implementation 直後 |
| **auto-check** | **構文・型・スタイル・カバレッジ等** の機械チェック (テスト実行を含む場合もあるが、目的はカバレッジ等の数値達成) | testing フェーズ等 |

両方が同じテストを走らせる場合があっても、**結果の解釈が違う**ため二重実行は許容する (キャッシュ最適化はプロジェクト側の判断)。

## 関連ファイル (本スキル配下)

| ファイル | 用途 |
|---|---|
| `resources/scripts/run-tests.sh` (.ps1) | スタック中立のテスト実行ラッパ (オーケストレータが直接 spawn する場合のヘルパ) |
| `resources/scripts/parse-results.py` | pytest / vitest / jest / go test の出力をパースして共通形式に集計 |
| `resources/report-template.md` | レポートのフォーマット |
