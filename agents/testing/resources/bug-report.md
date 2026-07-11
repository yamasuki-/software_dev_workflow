# 不具合票 — {{バグID}}

| 項目 | 内容 |
| ---- | ---- |
| バグID | B001 |
| タイトル |  |
| 機能ID |  |
| 重要度 | critical / high / medium / low |
| 検出フェーズ | unit / integration / e2e |
| 検出テストID |  |
| 報告日時 |  |
| ステータス | open / investigating / fixing / fixed / verified / closed |
| 反復回数 | 0 |

## 0. 概要

### 再現手順
1.
2.
3.

### 期待結果

### 実際の結果

### 関連ログ / スクリーンショット

---

## 反復記録

> 不具合修正は **「原因調査 → 設計修正 → テスト設計修正 → コード修正 → テスト実施」** の5ステップを1反復として実施する。
> テスト実施で Fail が残った場合、次の反復に進む。最初のテストが原因と異なる Fail の場合も新反復で原因調査からやり直す。

### 反復 #1

| 項目 | 内容 |
| ---- | ---- |
| 開始日時 |  |
| 終了日時 |  |
| 結果 | pass / fail / pending |

#### 1. 原因調査 (Investigation)

> **禁止**: 推測のみで原因を断定すること。
> **必須**: ログ追加・デバッグコード挿入・実行・観察等のエビデンスを最低1つ残すこと。

- 採用した調査手法:
  - [ ] ログ追加
  - [ ] デバッガ実行
  - [ ] テストランナーの詳細出力
  - [ ] スタックトレース解析
  - [ ] ネットワーク/DB のクエリログ
  - [ ] その他:
- 投入したデバッグコード / コマンド:

```
<実行したコマンド・追加したログ文・ブレークポイントの場所など>
```

- 取得した観察結果 (エビデンス):

```
<ログ出力, スタックトレース, 変数の値の実観測など>
```

- 特定した原因箇所 (ファイル:行):
- Root Cause (1〜3行で):
- 推測ではないことの確認: [ ] 観察によって裏付けられている

#### 2. 影響範囲の判定とハンドオフ (Impact Assessment & Handoff)

> **bug-fix は要件・設計・テスト設計を直接編集しない**。本 Step では根本原因の混入工程の特定 (分類) と影響範囲の特定のみを行い、必要なら該当する上流工程 (`requirements` / `basic-design` / `detailed-design` / `test-design`) に差し戻す。
> 実際の修正とそのレビュー、および下流工程の連鎖更新は **上流工程側・オーケストレータの責務**。
> 「コードに設計外の振る舞いがある」場合も、設計に追記してよいかは設計フェーズに判断させる (勝手に追記禁止)。

- 分類 (`classification`): 以下から1つ選ぶ (迷う場合はより上流に倒す)
  - [ ] `code_bug_only`                  — 設計どおり。実装にバグがあるだけ → 差し戻しなし
  - [ ] `test_design_gap`                — 実装は設計どおり。テスト設計の観点漏れ → `test-design` 差し戻し (影響層)
  - [ ] `design_error_detailed`          — 詳細設計に誤り → `detailed-design` 差し戻し → 下流 test-design 連鎖更新
  - [ ] `design_error_basic`             — 基本設計 (機能分割・アーキ) に誤り → `basic-design` 差し戻し → 下流連鎖更新
  - [ ] `undocumented_behavior`          — コードに設計外の振る舞いがある → 該当設計フェーズで「入れるべきか」検証
  - [ ] `requirements_misinterpretation` — 要件の誤り・解釈ミス → `requirements` 差し戻し (要件修正はユーザ確認必須) → 下流連鎖更新
- 差し戻し先フェーズ (`target_phase`): none / `test_design` / `detailed_design` / `basic_design` / `requirements`
- 対象機能ID:
- 影響範囲 (`impacted_FIDs` / `impacted_layers`):
- 影響範囲の導出根拠 (`impact_basis`: 参照元コード / depends_on / 更新設計ファイル):
- 判定根拠 (Step 1 のエビデンス):

##### 差し戻し結果 (`code_bug_only` 以外の場合のみ)

- `design_rerun_completed_at`:
- `design_review_per_feature_passed`: yes / no
- `design_review_cross_passed`: yes / no (requirements の場合は requirements-review + checkpoint)
- 更新された要件/設計/テスト設計ドキュメント:
- 下流工程の連鎖更新 (`downstream_rerun`: 各段の updated / skipped と根拠):
- `decision_notes` (特に `undocumented_behavior` の判断):
  - [ ] 入れるべき → 設計を更新済み (Step 3 へ進む)
  - [ ] 入れるべきでない → 設計は変更せず、Step 3-0 で「振る舞いが存在しないこと」の再現テストを Red 確認後、Step 4 で当該コードを除去
- `decisions.md` への追記: [ ] 実施済み

#### 3. テスト設計＋テストコードの修正 (Test Design & Code Fix) — **TDD**

> 不具合の検出層よりも **前工程の層** にテストが存在するなら、そのテスト設計と **テストコード両方** を修正・追加する。
> ピラミッド: unit ← integration ← e2e の順で、検出層より左側が前工程。
> - unit で検出 → 前工程なし (このステップはスキップ可)
> - integration で検出 → unit を見直し
> - e2e で検出 → unit と integration を見直し
>
> 必ず **テストが先に Fail することを確認してからコード修正に進む (TDD Red)**。
> テスト設計だけ書いて終わりにしない。実行可能なテストコードまで書いて Red を確認すること。

- 適用するテスト層:
  - [ ] unit (`docs/03_test_design/<FID>/unit-test.md`)
  - [ ] integration (`docs/03_test_design/<FID>/integration-test.md`)
  - [ ] e2e (`docs/03_test_design/<FID>/e2e-test.md`)
  - [ ] スキップ (検出層が最下層、または該当層が無効)
- スキップ理由 (該当時):
- 追加 / 修正したテストケースID:
- 追加 / 修正したテストコードのパス (テストツリー内):
- 追加 / 修正したテストの状態確認:
  - [ ] 修正前のコードで該当テストが **Fail することを確認** (Red)
  - [ ] 実行ログ・出力を `04_test_results/<FID>/<層>-result.md` の TDD 確認セクションに追記
  - [ ] テスト設計ドキュメント (`03_test_design/<FID>/*.md`) も同時更新

#### 4. コード修正 (Code Fix)

- 変更したファイル:
- 変更概要:
- 既存単体テストの再実行結果:
- コミット / PR (該当時):

#### 5. テスト実施 (Verification)

> 順に実行する:
> 1. 検出元のテストケース
> 2. 反復のステップ3で追加・修正したテストケース
> 3. 同一機能 (`<FID>`) の関連テスト全て (リグレッション・3 層)
> 4. 影響範囲のテスト — `impacted_FIDs` が非空なら必須 (影響機能 × 影響層。検出層より上位の層を含む)

| 観点 | テストID群 | 結果 |
| ---- | ---------- | ---- |
| 検出元テスト |  | pass / fail |
| 追加/修正テスト |  | pass / fail |
| 機能内リグレッション |  | pass / fail |
| 横断的リグレッション |  | pass / fail |

- 結果ドキュメント (追記先): `docs/04_test_results/<FID>/...`
- すべて Pass:
  - [ ] yes → 反復終了。本不具合は `verified` に進める
  - [ ] no  → 新たな観察結果を踏まえ **反復 #2