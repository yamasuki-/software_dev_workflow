# testing フェーズの 3 層シリアル化 / テスト実行ゲート (red・green) 詳細仕様

> `dev-workflow` SKILL.md §「testing フェーズの 3 層シリアル化」「テスト実行ゲート」から参照される詳細仕様。
> testing フェーズ、および test-implementation / implementation 完了直後の確認モード運用時に Read する。

## testing フェーズの 3 層シリアル化

`testing` フェーズは **3 つの layer (unit → integration → e2e) を厳密にシリアル** に実行する。

### 規律

1. **常に 1 層のみ実行**: `testing` Agent は `layer={unit|integration|e2e}` を入力で受け、その層のみテストを走らせる
2. **前層完了が次層の前提条件**:
   - `layers.unit.open_bugs = []` かつ `status = completed` → integration 開始可
   - `layers.integration.open_bugs = []` かつ `status = completed` → e2e 開始可
3. **層内の bug 全解消まで次に進まない**: 単体テストで fail が出たら bug-fix → testing (layer=unit, mode=retry) を **繰り返し**、open_bugs = 0 になって初めて結合テストへ
4. **bug-fix の戻り先は同じ layer の testing**:
   - bug-fix-review pass 後、`detected_layer` が `unit` なら `testing (layer=unit, mode=retry)` を spawn
   - mode=retry は **リグレッション含む層全体の再走** (部分実行禁止)
5. **3 層完了で初めて testing フェーズ完了**: 全 layer status=completed かつ open_bugs=[] のとき `phases.testing.status = completed` を立てる

### testing/<layer>-test-review/bug-fix の連動フロー (1 層)

```mermaid
flowchart TD
    Start[layer=L 開始 status=pending]
    Start --> T[testing layer=L mode=initial]
    T --> AC[auto-check phase=testing layer=L]
    AC --> AR[L-test-review per_feature → cross]
    AR --> BugCheck{open_bugs = []?}
    BugCheck -->|yes| Done[layer=L status=completed → 次層へ]
    BugCheck -->|no| BF[bug-investigation → bug-fix bug ごと反復]
    BF --> BFR[bug-fix-review]
    BFR -->|pass_and_verified| Retest[testing layer=L mode=retry リグレッション込み]
    BFR -->|pass_but_open| BF
    Retest --> AC2[auto-check phase=testing layer=L]
    AC2 --> AR2[L-test-review]
    AR2 --> BugCheck
```

L = unit / integration / e2e。レビュー Agent はそれぞれ `unit-test-review` / `integration-test-review` / `e2e-test-review`。

### spawn ブリーフ (testing / <layer>-test-review)

`Task(subagent_type="testing", ...)` のブリーフに **`layer`** と **`mode (initial|retry)`** を必ず含める:

```
プロジェクトルート: <PROJECT_ROOT>
対象機能ID: <FID>
layer: unit | integration | e2e   ← 必須
mode (testing): initial | retry    ← initial=初回、retry=bug-fix 後の再走 (リグレッション込み)

【今回のスコープ】
<layer> テストを実行し、結果を docs/04_test_results/<FID>/<layer>-test-result.md に保存。
Fail があれば不具合票を起票 (found_in_test_layer=<layer>)。
他層 (例: integration の場合の unit や e2e) には絶対に踏み込まない。
```

レビュー Agent は **layer に対応した専用 Agent** を呼ぶ:

| testing 実行 layer | spawn する review Agent |
|---|---|
| unit | `Task(subagent_type="unit-test-review", ...)` |
| integration | `Task(subagent_type="integration-test-review", ...)` |
| e2e | `Task(subagent_type="e2e-test-review", ...)` |

旧 `testing-review` Agent は削除済み (layer 別 3 専用 Agent に分離)。

## テスト実行ゲート (testing mode=red / green)

実装系フェーズ (test-implementation / implementation) 完了直後、**LLM レビューと auto-check の前** に `testing` Agent を **確認モード (mode=red / green)** で spawn してテストを実行する。テスト実行をレビュースキルから完全に分離するためのゲート (旧 `test-run` Agent は `testing` に統合済み)。

### いつ呼ぶか

| フェーズ完了 | spawn する testing | 期待 verdict |
|---|---|---|
| `test-implementation` 完了 | `testing` (mode=red) を機能数ぶん並行 | 全テスト Fail (Red) であること |
| `implementation` 完了 | `testing` (mode=green) を機能数ぶん並行 | 全テスト Pass (Green) であること |

### 確認モード spawn のブリーフ

`Task(subagent_type="testing", ...)` で呼び出す。手順は agent の system prompt に組み込み済み。

```
プロジェクトルート: <PROJECT_ROOT>
フェーズ: test-implementation | implementation
mode: red | green
対象機能ID: <FID>

【今回のスコープ】
mode=<red|green> で <phase> 直後のテストを実行し、結果レポートを
docs/04_test_results/<FID>/<phase>-<mode>-confirmation.md に保存。
状態 status.json の phases.<phase>.test_run を更新。

【判定の意味】
- mode=red で全 Fail かつ pass=0 → verdict=PASS (Red 確認 OK、次に進む)
- mode=red で 1 件でも pass → verdict=FAIL (test-implementation に差し戻し)
- mode=green で全 Pass かつ fail=0 → verdict=PASS (Green 確認 OK、次に進む)
- mode=green で 1 件でも fail → verdict=FAIL (implementation に差し戻し)

【戻り値】
- verdict (PASS | FAIL)
- executed, passed, failed, skipped, xfail (count)
- expected_state (red | green)
- report_path (str)
- log_path (str)
```

### 確認モード (red / green) 結果のハンドリング

1. **PASS**: そのまま **auto-check (per_feature)** に進む。LLM レビュー (per_feature) はその後
2. **FAIL**:
   - mode=red FAIL → `test-implementation` を再 spawn (failing でないテストを Red にする修正)
   - mode=green FAIL → `implementation` を再 spawn (failing テストを Pass させる修正)
   - 戻り値のレポートをブリーフに貼付
3. **3 回連続で同じ FAIL**: ユーザにエスカレーション (設計レベルの欠陥の可能性)

### 確認モードが走らないケース

以下の場合のみ確認モード (red / green) を spawn しなくてよい:
- プロジェクトに `.dev-workflow/rules/stack/stack-config.md` が **存在しない**
- `stack-config.md` の「テスト実行コマンド」セクションが空 (テスト未整備プロジェクト)
- ユーザが `decisions.md` で「red/green 確認スキップ」を明示承認している

それ以外では必ず spawn する。

### 確認モードと auto-check の関係

両者は **別目的**:

| スキル | 目的 | 走るテスト |
|---|---|---|
| **testing (mode=red/green)** | 全テストの **状態確認** (Red / Green) | 対象 FID の全層 (unit / integration / e2e) を実行し、ステータスを確認 |
| **auto-check** | **構文・型・スタイル・カバレッジ** の機械チェック | stack-config.md の自動チェックセクションで宣言されたコマンド (テスト実行を含むこともあるが、目的はカバレッジ閾値等) |

実装系フェーズでは順序が決まっている: **testing (mode=red/green) → auto-check → LLM レビュー (per_feature → cross)**。
