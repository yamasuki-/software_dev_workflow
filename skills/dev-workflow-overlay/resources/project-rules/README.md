# プロジェクトルール テンプレート集 (2 層構造)

このディレクトリのファイルを `<PROJECT_ROOT>/.dev-workflow/rules/` 配下にコピーして編集することで、
ベースの dev-workflow ワークフローに **プロジェクト固有のルールを上書き** できる。
インストール済みのベーススキル群 (`~/.claude/skills/dev-workflow/`, `~/.claude/skills/basic-design/`, … など) は一切変更しないので、複数プロジェクトで安全に再利用できる。

## 2 層の使い分け

ルールは **2 つの層** に分けて配置する:

```
<PROJECT_ROOT>/.dev-workflow/rules/
├─ stack/                    ← 言語/フレームワーク共通ルール
│   └─ stack-config.md + <phase>.md + ...
└─ project/                  ← このプロジェクト固有のルール
    └─ project-config.md + <phase>.md + ...
```

| 層        | 配置先                          | 目的                                                                       | 例                                                              |
| --------- | ------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `stack`   | `.dev-workflow/rules/stack/`    | 同じ技術スタックを使う複数プロジェクトで **再利用可能** な共通ルール        | Python+FastAPI 用、React+Vite 用、Go+gRPC 用 …                  |
| `project` | `.dev-workflow/rules/project/`  | このプロジェクトだけの **個別事情** (ドメイン用語/外部依存/例外的規約 等)   | 「内部の Slack 通知形式」「特殊な認可ルール」「監査ログ詳細」 等 |

両方の層を同時に使うことも、片方だけ使うこともできる。

## 優先順位 (高→低)

1. `project/<phase>.md` の `OVERRIDE` / `DISABLE`
2. `project/<phase>.md` の `ADD` / `ADDITIONAL_ARTIFACTS`
3. `stack/<phase>.md` の `OVERRIDE` / `DISABLE`
4. `stack/<phase>.md` の `ADD` / `ADDITIONAL_ARTIFACTS`
5. ベース `~/.claude/skills/<phase>/SKILL.md`

両層が `ADD` を出した場合は **両方とも適用** される。`OVERRIDE` / `DISABLE` が矛盾する場合は project が勝ち、その旨を `decisions.md` に記録する。

## ファイル一覧 (両層で同じ構造)

| ファイル                       | 役割                                                              | 配置先 (推奨)             |
| ------------------------------ | ----------------------------------------------------------------- | ------------------------ |
| `stack-config.md`              | スタック全体共通 (言語/FW/規約・テスト基盤・CI など)              | stack/ のみ              |
| `project-config.md`            | プロジェクト固有メタ情報・ドメイン用語・例外的規約                | project/ のみ            |
| `basic-design.md`              | basic-design フェーズへの追加/上書きルール                        | 両層に置ける             |
| `detailed-design.md`           | detailed-design フェーズへの追加/上書きルール                     | 両層に置ける             |
| `test-design.md`               | test-design フェーズへの追加/上書きルール                         | 両層に置ける             |
| `test-implementation.md`       | test-implementation フェーズへの追加/上書きルール                 | 両層に置ける             |
| `implementation.md`            | implementation フェーズへの追加/上書きルール                      | 両層に置ける             |
| `testing.md`                   | testing フェーズへの追加/上書きルール                             | 両層に置ける             |
| `bug-fix.md`                   | bug-fix フェーズへの追加/上書きルール                             | 両層に置ける             |
| `basic-design-review.md` 他    | 各レビューフェーズへの追加チェックリスト                          | 両層に置ける             |
| `extra-phases.md`              | ワークフローに追加挿入するフェーズの定義                          | 両層に置ける             |

不要なファイル/層は置かなくてよい (全て任意)。

## セットアップ例

bash / macOS / Linux:

```bash
REPO_ROOT="$HOME/dev/claudecode_settings"
PROJECT_ROOT="$HOME/projects/my-app"
TEMPLATES="$REPO_ROOT/skills/dev-workflow-overlay/resources/project-rules"

# 2 層のディレクトリを作成
mkdir -p "$PROJECT_ROOT/.dev-workflow/rules/stack"
mkdir -p "$PROJECT_ROOT/.dev-workflow/rules/project"

# stack 層 (言語/FW 共通) のテンプレをコピー
cp "$TEMPLATES/stack-config.md"     "$PROJECT_ROOT/.dev-workflow/rules/stack/"
cp "$TEMPLATES/implementation.md"   "$PROJECT_ROOT/.dev-workflow/rules/stack/"  # スタック由来の実装規約
cp "$TEMPLATES/testing.md"          "$PROJECT_ROOT/.dev-workflow/rules/stack/"  # スタック由来のテスト規約

# project 層 (プロジェクト固有) のテンプレをコピー
cp "$TEMPLATES/project-config.md"   "$PROJECT_ROOT/.dev-workflow/rules/project/"
cp "$TEMPLATES/basic-design.md"     "$PROJECT_ROOT/.dev-workflow/rules/project/"  # ドメイン固有の機能分割規約
```

PowerShell (Windows):

```powershell
$RepoRoot    = "$env:USERPROFILE\github\claudecode_settings"
$ProjectRoot = "$env:USERPROFILE\projects\my-app"
$Templates   = "$RepoRoot\skills\dev-workflow-overlay\resources\project-rules"

New-Item -ItemType Directory -Force -Path "$ProjectRoot\.dev-workflow\rules\stack"   | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectRoot\.dev-workflow\rules\project" | Out-Null

# stack 層
Copy-Item "$Templates\stack-config.md"   "$ProjectRoot\.dev-workflow\rules\stack\"
Copy-Item "$Templates\implementation.md" "$ProjectRoot\.dev-workflow\rules\stack\"

# project 層
Copy-Item "$Templates\project-config.md" "$ProjectRoot\.dev-workflow\rules\project\"
Copy-Item "$Templates\basic-design.md"   "$ProjectRoot\.dev-workflow\rules\project\"
```

## 共通フォーマット (全ファイル)

```
# <phase> — <stack 由来 / project 由来> rules

## ADD
- 追加するルール (本フェーズのチェック項目に加算される)

## OVERRIDE
- ベース指示の特定部分を **置き換え** るルール

## DISABLE
- ベース指示の特定部分を **無効化** するルール

## ADDITIONAL_ARTIFACTS
- 本フェーズで追加生成すべきファイル

## REVIEW_EXTRAS
- このフェーズに対応するレビューで追加チェックする項目
```

## 後方互換

旧バージョンの `<PROJECT_ROOT>/.dev-workflow/rules/<file>.md` (サブディレクトリなしの直置き) も後方互換でサポート。直置きされたファイルは **project 層と同じ扱い** で読み込まれる。可能なら `project/` 配下に移すことを推奨。
