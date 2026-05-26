---
name: auto-check
description: フェーズ完了直後・LLM レビューの前段に走る「機械チェックゲート」。markdownlint / mermaid-cli / linter / typecheck / coverage 等のツールを横断的に実行し、MUST / SHOULD / MAY の 3 階層で pass/fail を判定する。各 stack-presets の `stack-config.md` から該当フェーズ向けコマンドを取り出して順次実行し、結果を `docs/06_reviews/<FID>/<phase>-auto-check.md` に保存する。未インストールツールは skip + warn 扱いとする。
---

# auto-check — 機械チェックゲート

## 役割

各フェーズ (basic-design / detailed-design / test-design / test-implementation / implementation / testing / bug-fix) の **per_feature レビューの直前** に走る、ツールによる自動チェック。

- ツールが客観的に判定できる項目 (構文 / 型 / lint / coverage / typo / リンク切れ / 重複コード / 依存脆弱性) を機械的に判定する
- 結果を LLM レビュースキルに引き渡し、LLM は **設計意図・命名・読みやすさ・横断一貫性などツールでは判定できない観点** に集中する
- これにより LLM レビューが安定し、トークン消費も減る

## 入出力

### 入力 (オーケストレータからのブリーフ)

```
phase:            basic-design | detailed-design | test-design | test-implementation
                  | implementation | testing | bug-fix
mode:             per_feature | cross
target_fids:      [F001, F002, ...] または "ALL"
project_root:     <PROJECT_ROOT 絶対パス>
```

### 出力 (レポートファイル + 戻り値サマリ)

| 項目 | 配置 / 戻り値 |
|---|---|
| 機械チェックレポート | `<PROJECT_ROOT>/docs/06_reviews/<FID>/<phase>-auto-check.md` (per_feature) / `docs/06_reviews/cross/<phase>-auto-check.md` (cross) |
| 判定 | `must_passed` (bool), `should_warnings` (count), `may_info` (count), `skipped_missing_tools` (list) |
| 状態ファイル更新 | `.dev-workflow/features/<FID>/status.json` の `phases.<phase>.auto_check` |

## ツールの 3 階層

| 階層 | 意味 | 失敗時の挙動 |
|---|---|---|
| **MUST** | スタック標準として必須のツール (例: linter, typecheck, テストランナー) | **fail → ゲートで停止**。フェーズを差し戻し |
| **SHOULD** | 強く推奨されるが、プロジェクト判断で猶予あり (例: 依存脆弱性、複雑度) | warn 出力、レポートに記録、ゲートは通す |
| **MAY** | 任意 (例: mutation testing, リンク切れ) | info のみ、出力に列挙 |

`stack-config.md` の **自動チェック (MUST / SHOULD / MAY)** セクションから読み取る (W2 で追加)。

## 未インストール時の挙動

ツールが環境にインストールされていない場合:

- MUST であっても **fail とせず skip + warn** にする
- レポートの「skipped (tool not installed)」に記録
- 戻り値 `skipped_missing_tools` に列挙し、オーケストレータと LLM レビューに見せる
- CI では事前に全 MUST ツールがインストール済みである前提 (環境構築の責務はプロジェクト側)

> これにより、ローカル開発でツール未整備でもワークフローが止まらない。本来 fail すべきだった場合は LLM レビューと CI が拾う。

## 実行手順

### Step 1: ルール読み込み

1. プロジェクトルートを起点に、`stack-config.md` を以下の優先順で探す:
   1. `<PROJECT_ROOT>/.dev-workflow/rules/project/stack-config.md` (任意、project 層の上書き)
   2. `<PROJECT_ROOT>/.dev-workflow/rules/stack/stack-config.md` (通常はプリセット由来)
2. 見つかった `stack-config.md` から「自動チェック (MUST / SHOULD / MAY)」セクションを取り出し、現在の `phase` に該当する block と「全フェーズ共通」block をマージする
3. project 層に同じ block があれば、ベース (stack) と「ADD 加算 / OVERRIDE 置換 / DISABLE 削除」のルールでマージする

### Step 2: ツール存在チェック

各コマンドを実行する前に、`scripts/check-tools.sh` を呼んで `--version` で存在確認する。
未インストールツールは実行リストから除き、skip リストに移す。

### Step 3: 実行

`scripts/run-checks.sh <phase>` を実行する。スクリプトは:

1. MUST のコマンドを順次実行。1 つでも non-zero exit したら `must_passed = false` でも残りを継続実行 (全結果をレポートに残すため)
2. SHOULD のコマンドを順次実行。non-zero exit は warning として記録 (継続)
3. MAY のコマンドを順次実行。結果は info として記録 (継続)
4. すべての stdout / stderr を集約し、コマンドごとに 50 行までを抜粋してレポートに貼付

### Step 4: レポート生成

`resources/report-template.md` のフォーマットに従ってレポートを書く。

```markdown
# <phase> — auto-check 結果 (mode: <per_feature|cross>, target: <FID|ALL>)

実行日時: <ISO 8601>
実行環境: <OS> / <Node|Python|Go 等のバージョン>

## サマリ

| 階層   | 実行 | pass | fail | skipped (missing) |
|--------|------|------|------|-------------------|
| MUST   | N    | N    | N    | N                 |
| SHOULD | N    | N    | N    | N                 |
| MAY    | N    | N    | N    | N                 |

判定: **PASS** または **FAIL (MUST 失敗あり)**

## MUST 詳細

### <ツール名 / コマンド>
- exit code: 0 | <non-zero>
- 出力 (先頭 50 行):
  ```
  ...
  ```

## SHOULD 詳細
...

## MAY 詳細
...

## skipped (tool not installed)
- <ツール名>: install hint = `<コマンド>`
```

### Step 5: 状態ファイル更新

`<PROJECT_ROOT>/.dev-workflow/features/<FID>/status.json` の該当フェーズ block に追記:

```json
{
  "phases": {
    "<phase>": {
      "auto_check": {
        "executed_at": "<ISO 8601>",
        "must_passed": true,
        "should_warnings": 2,
        "may_info": 1,
        "skipped_missing_tools": ["lychee"],
        "report_path": "docs/06_reviews/<FID>/<phase>-auto-check.md"
      }
    }
  }
}
```

cross モードの場合は `<PROJECT_ROOT>/.dev-workflow/project.json` の `cross_auto_check.<phase>` に同等の block を書く。

### Step 6: 終了サマリ

オーケストレータに返すサマリ (Agent の戻り値):

```
auto-check 完了
phase: <phase>
mode: <per_feature|cross>
target: <FID|ALL>

MUST: <pass数>/<実行数> (skipped: <数>)
SHOULD warnings: <数>
MAY info: <数>

判定: PASS|FAIL
report: <絶対パス>

次のアクション (オーケストレータが判断):
- PASS → 対応する LLM レビューに進む
- FAIL → このフェーズを差し戻し
```

## per_feature と cross の使い分け

| mode | 対象 | レポート配置 | 主な目的 |
|---|---|---|---|
| `per_feature` | 1 機能 (`<FID>`) | `docs/06_reviews/<FID>/<phase>-auto-check.md` | その機能の成果物が壊れていないか機械的に検証 |
| `cross` | プロジェクト全体 | `docs/06_reviews/cross/<phase>-auto-check.md` | 全機能を横断的にスキャン (重複コード / 命名一貫性 / リンク切れ) |

横断レビューに対応する cross モードの auto-check では、jscpd / lychee などの「全体スキャン」系ツールが活きる。

## 注意事項

- **コード本体を書き換えない**: lint の autofix (例: `ruff format`、`go fmt`、`prettier --write`) は **実行しない**。format-check のみ。修正は実装フェーズに戻す
- **destructive な操作禁止**: `rm -rf`, DB drop, ネットワーク経由のパッケージインストール (`pip install`, `npm install` 等) は実行しない
- **タイムアウト**: 各コマンド 5 分、全体 30 分でハードリミット。超過時は skip + warn
- **コマンド失敗 ≠ ツール未インストール**: exit code を見て区別 (typically 127 が "command not found")
- **secret を出力に含めない**: コマンド出力に環境変数値が含まれる場合があるため、レポートに貼付前に `.env` 系のキー名を伏字に

## 関連ファイル (本スキル配下)

| ファイル | 用途 |
|---|---|
| `resources/scripts/check-tools.sh` (.ps1) | ツール存在確認 |
| `resources/scripts/run-checks.sh` (.ps1) | MUST/SHOULD/MAY 順次実行 |
| `resources/scripts/parse-stack-config.py` | `stack-config.md` から `[自動チェック]` セクションを抽出 |
| `resources/scripts/check-mermaid.sh` (.ps1) | Markdown から Mermaid ブロックを抽出して mmdc で検証 |
| `resources/report-template.md` | レポートのフォーマット |

## 言語別ツール一覧 (参考)

実際のコマンドは各 `stack-presets/<stack-name>/stack-config.md` の **自動チェック** セクションで定義する。
ここに列挙するのはあくまで参考。

### 全フェーズ共通 (言語非依存)

| 階層 | ツール | 用途 |
|---|---|---|
| MUST | markdownlint-cli2 | Markdown 構文 |
| MUST | mermaid-cli (mmdc) | Mermaid 構文検証 (scripts/check-mermaid.sh) |
| SHOULD | textlint + prh | 日本語表記揃え |
| SHOULD | typos | typo 検出 |
| MAY | lychee | リンク切れ検出 |
| MAY | jscpd | 重複コード検出 (cross モード時) |
| MAY | semgrep | パターンマッチ静的解析 |

### スタック別 (例: Python+FastAPI)

| 階層 | ツール | 用途 |
|---|---|---|
| MUST | ruff check / ruff format --check | lint / format |
| MUST | mypy --strict | 型 |
| MUST | pytest --cov-fail-under=80 (testing フェーズ) | テスト + カバレッジ |
| SHOULD | pip-audit | 依存脆弱性 |
| MAY | mutmut | mutation testing |
