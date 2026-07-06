# 自動チェックゲート (auto-check) 詳細仕様

> `dev-workflow` SKILL.md §「自動チェックゲート (auto-check)」から参照される詳細仕様。
> auto-check を spawn する場面 (各レビューの直前) で Read する。

LLM レビューの前段で走る **機械チェック**。`auto-check` という汎用 Agent を各フェーズ用に呼び出して使う。

## いつ呼ぶか

- 各フェーズの per_feature レビューの **直前**: 機能数ぶん並行 spawn
- 各フェーズの cross レビューの **直前**: cross スキャン系ツール (jscpd / lychee 等) が `stack-config.md` にあれば 1 回 spawn (なければ skip 可)

## auto-check spawn のブリーフ

`Task(subagent_type="auto-check", ...)` で呼び出す。手順は agent の system prompt に組み込み済み。

```
プロジェクトルート: <PROJECT_ROOT>
フェーズ: <phase>            ← basic-design | detailed-design | ...
mode: <per_feature | cross>
対象機能ID: <FID> または "ALL"

【今回のスコープ】
本フェーズの自動チェック (MUST / SHOULD / MAY) を実行し、
結果レポートを docs/06_reviews/<FID>/<phase>-auto-check.md
(cross の場合 docs/06_reviews/_cross/<phase>-auto-check.md) に保存。
status.json の phases.<phase>.auto_check を更新。

【判定の意味】
- MUST 全 pass (skipped 含む) → ゲート通過。次の LLM レビューへ
- MUST に fail あり → ゲート停止。本フェーズを差し戻し
- SHOULD warning / MAY info はレポートに記録するだけ。LLM レビューが見る

【戻り値】
- must_passed (bool)
- should_warnings (count)
- may_info (count)
- skipped_missing_tools (list)
- report_path (str)
- verdict ("PASS" | "FAIL")
```

## auto-check 結果のハンドリング

1. **PASS**: そのまま LLM レビュー (per_feature → cross) に進む。SHOULD warning と MAY info はレビューのブリーフに引き渡す
2. **FAIL (MUST 失敗あり)**:
   - 該当フェーズの作業を再 spawn (auto-check レポートを briefing に貼付)
   - 修正完了後に auto-check と LLM レビューを順に再 spawn
3. **未インストールツール (skipped_missing_tools 非空)**:
   - レポートに残し、`open-questions.md` に「ローカル環境で <tool> 未インストール」を 1 件追記
   - CI 側で必ず走ることをユーザに確認してもらう (ゲートは止めない)
4. **3 回連続で同じ MUST fail**: ユーザにエスカレーション (環境問題 / プロジェクトルール側の問題の可能性)

## auto-check スキップ条件

auto-check には **組み込みチェック (ID トレーサビリティ検証、stack-config 不要)** があるため、原則 **常に spawn する**。

- `.dev-workflow/rules/stack/stack-config.md` が **存在しない** 場合: ツール由来のチェック (linter / typecheck 等) は skip されるが、**組み込みチェックのために auto-check は spawn する**
- ユーザが明示的に `decisions.md` で「auto-check は CI 側に寄せる」と決めている場合のみ、spawn を省略してよい
