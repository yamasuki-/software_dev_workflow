# ワークフロー全体像

## エージェント構成

```mermaid
flowchart TD
    User["ユーザ"] <--> Orch["dev-workflow<br/>オーケストレータ"]
    Orch -. "Task ツールで spawn" .-> BDA["basic-design"]
    Orch -. spawn .-> DDA["detailed-design"]
    Orch -. spawn .-> TDA["test-design"]
    Orch -. spawn .-> TIA["test-implementation<br/>TDD Red"]
    Orch -. spawn .-> ImpA["implementation<br/>TDD Green"]
    Orch -. spawn .-> TstA["testing"]
    Orch -. spawn .-> BugA["bug-fix"]
    BDA & DDA & TDA & TIA & ImpA & TstA & BugA <-->|"read/write"| FS[(".dev-workflow/<br/>docs/<br/>src/<br/>tests/")]
    Orch <-. read .-> FS
```

- オーケストレータはユーザとの長期対話を担当。設計ドキュメントやコードは原則書かない。
- 各サブエージェントは **フレッシュコンテキスト** で起動し、必要情報をブリーフとファイルから取得して作業する。
- 状態の引き継ぎはすべて `.dev-workflow/` ファイル経由。

## 全体フロー

```mermaid
flowchart TD
    A["要件入力<br/>ファイル or チャット"] --> B["dev-workflow<br/>初期化"]
    B --> C["basic-design"]
    C --> CR{"basic-design-review"}
    CR -->|fail| C
    CR -->|pass| C1["機能ID確定<br/>F001, F002, F003 + COMMON 候補"]

    subgraph Batch ["フェーズバッチ: 同じフェーズを全機能まとめて → 2 段レビュー"]
      direction TB
      DDBatch["detailed-design<br/>全機能を並行 spawn"]
      DDBatch --> DDR1{"review per_feature<br/>機能ごと並行"}
      DDR1 -->|fail| DDBatch
      DDR1 -->|"all pass"| DDR2{"review cross<br/>全機能横断"}
      DDR2 -->|fail| DDBatch
      DDR2 --> TDBatch["test-design"]
      TDBatch --> TDR1{"review per_feature"}
      TDR1 --> TDR2{"review cross"}
      TDR2 --> TIBatch["test-implementation<br/>TDD Red"]
      TIBatch --> TIR1{"review per_feature"}
      TIR1 --> TIR2{"review cross"}
      TIR2 --> ImplBatch["implementation<br/>COMMON 先行 → 各機能<br/>TDD Green"]
      ImplBatch --> IR1{"review per_feature"}
      IR1 --> IR2{"review cross<br/>重複/共通化検出"}
      IR2 --> TestBatch["testing"]
      TestBatch --> TR1{"review per_feature"}
      TR1 --> TR2{"review cross"}
    end

    C1 --> DDBatch
    TR2 -->|"fail<br/>未実施あり"| TestBatch
    TR2 -->|"pass + Fail なし"| L["最終レポート<br/>00_final_report.md"]
    TR2 -->|"pass + Fail あり"| J["bug-fix<br/>5ステップ反復"]
    J --> JR{"bug-fix-review"}
    JR -->|fail| J
    JR -->|pass_but_open| J
    JR -->|pass_and_verified| TestBatch
```

**重要なポイント:**
- フェーズはバッチで進む (機能ごとに最後まで通さない)
- 各フェーズは全機能の作業が揃ってから **auto-check (機械チェック) → 個別レビュー (per_feature, 並行) → 横断レビュー (cross, 1回)** の **3 段ゲート** を通って初めて次フェーズへ
- **auto-check** はツール (markdownlint / mermaid-cli / linter / typecheck / カバレッジ等) を MUST/SHOULD/MAY の 3 階層で実行する機械チェック。MUST が pass しなければ LLM レビューに進まない
- 個別レビューは「per-feature 内の整合」を、横断レビューは「機能間の一貫性と共通化機会」をそれぞれ集中して検証
- 改修・新機能追加で1機能だけ進める場合も同じフロー (バッチ対象が1機能になるだけで、cross も自動的に縮退)

## 3 段ゲートの動作 (auto-check → per_feature → cross)

各フェーズ完了直後、LLM レビューの前段に必ず **auto-check** が走る。

```mermaid
flowchart TD
    Phase[フェーズ作業 全機能 並行 spawn]
    Phase --> AC1[auto-check mode=per_feature N並行 spawn]
    AC1 --> AC1R{MUST 全 pass?}
    AC1R -->|fail| BackAC[該当機能の作業を再 spawn auto-check レポートを briefing に]
    BackAC --> Phase
    AC1R -->|pass| R1[LLM レビュー mode=per_feature N並行 spawn]
    R1 --> R1R{全機能 pass?}
    R1R -->|fail| Back1[該当機能の作業を再 spawn]
    Back1 --> Phase
    R1R -->|pass| AC2[auto-check mode=cross 1回 spawn 横断ツール]
    AC2 --> AC2R{MUST 全 pass?}
    AC2R -->|fail| Back2[横断 issue として再 spawn]
    Back2 --> Phase
    AC2R -->|pass| R2[LLM 横断レビュー mode=cross 1回 spawn]
    R2 --> R2R{pass?}
    R2R -->|fail| Back3[該当機能再 spawn または COMMON 立てる]
    Back3 --> Phase
    R2R -->|pass| Next[次フェーズへ]
```

- **auto-check 自体は新規スキル** (`~/.claude/skills/auto-check/`) として配置
- 走るツールは `<PROJECT_ROOT>/.dev-workflow/rules/stack/stack-config.md` の「自動チェック (MUST / SHOULD / MAY)」セクションで宣言 (stack-presets が提供するスタックごとのプリセットを使うのが標準)
- 未インストールツールは **skip + warn** で扱われ、ゲートは止まらない (本来 fail すべきだったケースは CI 側で検出する前提)
- 横断スキャン系ツール (jscpd / lychee 等) がない場合、cross モードの auto-check は skip 可

## TDD の規律

詳細設計の後、プロダクトコードを書くより前に必ずテストコードを書く。

```mermaid
flowchart LR
    DD[detailed-design]
    TD[test-design<br/>ケース設計]
    TI[test-implementation<br/>テストコード作成<br/>＝Red]
    IM[implementation<br/>＝Green / Refactor]

    DD --> TD --> TI --> IM
    IM -.tests pass.-> Next[次フェーズ]
```

- `test-implementation` のゴール: 全テストが **必ず Fail** することを確認 (Red)
- `implementation` のゴール: 失敗テストを **最小実装で Pass** させる (Green)、その後 Refactor
- `implementation` の中で **新規テストを書くことは禁止** (必要なら test-implementation か bug-fix に戻る)

## bug-fix の5ステップ反復ループ (設計差し戻し型)

**bug-fix は設計を直接編集しない**。設計変更が必要な場合は該当設計フェーズ (`basic-design` / `detailed-design`) に差し戻し、そこの 2 段レビュー (per_feature + cross) を通って初めて設計が確定。bug-fix は調整役。

```mermaid
flowchart TD
    Start([不具合 open]) --> S1[Step 1 原因調査 推測禁止 エビデンス必須]
    S1 --> S2[Step 2 影響範囲の判定とハンドオフ 分類のみ 直接編集禁止]
    S2 -->|code_bug_only| S3
    S2 -->|design_error_detailed| HD[detailed-design 差し戻し 2段レビュー]
    S2 -->|design_error_basic| HB[basic-design 差し戻し 2段レビュー]
    S2 -->|undocumented_behavior| HC[該当設計フェーズが妥当性判定]
    S2 -->|requirements_misinterpretation| HB
    HD --> S3
    HB --> S3
    HC -->|入れる 設計更新| S3
    HC -->|入れない コード除去| S4
    S3[Step 3 前工程テスト設計修正 + テストコード追加 TDD]
    S3 --> S4[Step 4 コード修正]
    S4 --> S5[Step 5 テスト実施 検出元 追加分 リグレッション]
    S5 -->|全 Pass| Verified([verified])
    S5 -->|Fail あり| S1
```

**Step 2 の分類と差し戻し先:**

| 分類                            | 差し戻し先                                  |
| ------------------------------- | ------------------------------------------- |
| `code_bug_only`                 | なし (Step 3 へ)                            |
| `design_error_detailed`         | `detailed-design`                           |
| `design_error_basic`            | `basic-design`                              |
| `undocumented_behavior`         | 該当設計フェーズで「入れるべきか」判断       |
| `requirements_misinterpretation`| `basic-design` (必要なら要件もユーザ確認)    |

**前工程テスト設計修正の適用ルール (Step 3):**

| 検出層 | 補強対象の前工程層 |
|--------|--------------------|
| unit | なし。スキップ可 |
| integration | unit |
| e2e | unit と integration |

反復が 5 回を超えても解消しない不具合 (特に差し戻しが繰り返される場合) は、設計の根本欠陥の可能性が高い → ユーザにエスカレーション。

## フェーズと成果物の対応

| フェーズ                 | 成果物のパス                                                    | 形式 |
| ------------------------ | --------------------------------------------------------------- | ---- |
| 要件入力                 | `docs/requirements/requirements.md`                             | md   |
| 基本設計                 | `docs/01_basic_design/{system-overview, feature-list, system-architecture, non-functional}.md` | md + Mermaid |
| 詳細設計 (機能毎)        | `docs/02_detailed_design/<FID>/{ui-design, functional-design, state-transition, db-design, sequence}.md` | md + Mermaid |
| テスト設計 (機能毎)      | `docs/03_test_design/<FID>/{unit-test, integration-test, e2e-test}.md` | md   |
| テストコード (機能毎)    | `tests/{unit,integration,e2e}/<FID>/...` (プロジェクト固有)    | コード |
| Red 確認ログ (機能毎)    | `docs/04_test_results/<FID>/*.md` の Red 確認セクション         | md   |
| 実装                     | `src/...` (プロジェクト固有)                                   | コード |
| テスト実行 (機能毎)      | `docs/04_test_results/<FID>/{unit-test-result, integration-test-result, e2e-test-result}.md` | md   |
| 不具合票                 | `docs/05_bug_reports/B<番号>.md`                               | md   |
| レビュー票               | `docs/06_reviews/<basic | <FID>/<phase>>-review.md`            | md   |

## 進捗管理ファイル

```
.dev-workflow/
├─ project.json             # プロジェクト全体の進捗 (current_phase, features 配列)
├─ open-questions.md        # 未解決の確認事項
├─ decisions.md             # 確定した決定事項
└─ features/
   └─ <FID>/
      ├─ status.json        # 機能ごとのフェーズ状態
      ├─ tasks/<TID>.json   # 実装タスクごとの状態
      └─ bugs/<BID>.json    # 不具合ごとの状態
```

## セッション間の継続のしかた

1. ユーザが `dev-workflow` を再度起動
2. スキルが `.dev-workflow/project.json` を Read
3. 各機能の `status.json` を Read
4. `open-questions.md` の open 項目を読み上げ
5. **再開サマリ** をユーザに提示し、次のアクションを確認
6. 適切なフェーズスキルに引き継ぐ

## 確認のハイブリッド方針

| 確認タイミング   | 対象                                                                |
| ---------------- | ------------------------------------------------------------------- |
| **即時**         | 要件の解釈、アーキ選定、機能スコープ、DB既存データ影響、セキュリティ、設計外の実装判断 |
| **チェックポイント (フェーズ末)** | カバレッジ目標、軽微なUI挙動、エラーメッセージ文言、コードスタイルなど |

いずれも質問する前に必ず `open-questions.md` に追記する。回答が確定したら `decisions.md` に転記する。

## ID 採番ルールの実装メモ

- 機能ID: `basic-design` が連番採番。`project.json` の `features` 配列順 + 1。
- タスクID: `implementation` が機能ごとに採番。`<FID>-T<連番2桁>`。
- 不具合ID: `testing` が **プロジェクト全体で一意** に採番。`project.json` の `next_bug_id` カウンタを参照・更新。
- テストID: `test-design` が機能ごと層ごとに採番。

## 状態の遷移ルール (簡易版)

```mermaid
stateDiagram-v2
    [*] --> pending
    pending --> in_progress
    in_progress --> completed
    in_progress --> blocked
    blocked --> in_progress
    completed --> [*]
```

- `blocked` は `open-questions.md` で未解決の質問待ちなどで使う。
- 中断時は `in_progress` のまま `notes` を残す (`blocked` ではない)。
