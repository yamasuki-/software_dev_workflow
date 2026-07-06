# Git 統合 (commit ゲート) 詳細仕様

> `dev-workflow` SKILL.md §「Git 統合 (commit ゲート)」から参照される詳細仕様。
> commit を実行する場面・ブランチ前提を確認する場面で Read する。

ワークフローの品質ゲートと Git 履歴を 1:1 で対応づける。**git 操作はオーケストレータのみ** が行う (サブエージェントは禁止。ブリーフにも明記済み)。

## 前提: 専用ブランチ

- ワークフロー開始時 (Step 1) に現在ブランチを確認し、**`main` / `master` / `develop` 等の保護対象ブランチ上では開始しない** (停止してユーザに専用ブランチへの切替を依頼)
- 専用ブランチの命名例: `dev-workflow/<プロジェクト名>`。作成はユーザ承認のもと `git switch -c` で行ってよい
- git リポジトリでないプロジェクトでは、ユーザの選択 (`git init` する / Git 統合なしで進める) を `decisions.md` に記録。「なし」の場合、本節の commit はすべてスキップする

## commit ポイント (ゲート通過時に commit)

ゲートを通過するたびに、その時点の変更すべて (`git add -A`: docs / src / tests / `.dev-workflow/` を含む) を 1 commit にする:

| ゲート | commit メッセージ (1 行目) |
|---|---|
| `requirements-review` pass | `[dev-workflow] requirements: review pass (R-001..R-NNN)` |
| human-checkpoint approve / skip | `[dev-workflow] checkpoint: <phase> approved` (skip 時は `skipped`) |
| `basic-design-review` pass | `[dev-workflow] basic-design: review pass (F001..Fn)` |
| `<phase>` cross review pass (detailed-design / test-design / test-implementation / implementation) | `[dev-workflow] <phase>: cross review pass` |
| `security-review` cross pass | `[dev-workflow] security-review: pass` |
| testing layer 完了 (review pass かつ `open_bugs = 0`) | `[dev-workflow] testing(<layer>): completed` |
| `bug-fix-review` が `pass_and_verified` | `[dev-workflow] bug-fix <BID>: verified` |
| 最終レポート作成 | `[dev-workflow] project completed: final report` |

- メッセージ本文 (2 行目以降) に、対象 FID と pass したレビュー票のパスを 1〜3 行で書く
- **fail → 再 spawn の修正中は commit しない** (ゲートを通過した状態だけが履歴に残る)。セッション中断時のみ例外として `[dev-workflow] WIP: <どこまで進んだか>` の WIP commit を作ってよい (再開後、次のゲート通過 commit に内容を引き継ぐ)

## commit 前のユーザ確認 (必須・全 commit 共通)

**`git commit` を実行する前に、必ずユーザに確認を取り、承認を得てから commit する。** WIP commit・revert を含め例外なし。確認なしの自動 commit は禁止。

1. commit 直前に、以下を 1 メッセージでユーザに提示する:
   - 提案する **commit メッセージ** (1 行目 + 本文)
   - **対象ブランチ名** (専用ブランチであることの再確認)
   - **変更サマリ**: `git status --short` と `git diff --stat` の結果 (ファイル数・追加/削除行数)
   - 必要に応じて主要差分の要約 (大きい場合はファイル単位の要点)
2. ユーザの応答で分岐:

   | 応答 | 動作 |
   |---|---|
   | `commit` / 「承認」/「OK」など肯定 | `git add -A` → `git commit` を実行。次のステップへ |
   | `<メッセージ修正>` (例: 「メッセージを〜にして」) | 指示どおり commit メッセージを直して再提示 → 再確認 |
   | `<除外指定>` (例: 「このファイルは含めないで」) | 該当を除外して `git add` (`-A` を使わず明示パス指定) → 差分を再提示 → 再確認 |
   | `skip` / 「今はしない」 | commit せず次へ進む (`decisions.md` に「ユーザ判断で <ゲート> の commit を見送り」を記録)。未 commit 変更は次のゲートの確認時にまとめて提示 |

3. Cowork では `AskUserQuestion` (選択肢: commit する / メッセージを直す / 今はしない) を使ってよい。Claude Code ではチャットで確認する。
4. **ユーザ承認のないまま commit を実行してはならない**。承認待ちでターンを終えること。

> **human-checkpoint 直後の commit**: チェックポイント承認 (approve) のターンで、続けて commit 確認を 1 メッセージにまとめてよい (「承認します。続けて以下の内容で commit します: …」と提示し、approve = commit 承認も兼ねる)。確認の回数を減らすための運用で、commit 前確認の原則は満たす。

## 禁止事項 (履歴は必ず人が確認できる状態を保つ)

- **`git push` をしない**。push はユーザが commit 履歴を確認したうえで手動で行う
- **commit 履歴の削除・改変を一切しない**: `git reset` (--soft / --mixed / --hard すべて)、`git rebase`、`git commit --amend`、`git push --force`、ブランチ/タグの削除、`git checkout -- <file>` / `git restore` による変更破棄、を禁止
- やり直しは **前方修正のみ**: 誤った内容が commit されても、修正を新しい commit として積む (`git revert` は前方修正なので可)
- 例外はユーザが明示的に指示した場合のみ。その際は指示内容を `decisions.md` に記録してから実施する
