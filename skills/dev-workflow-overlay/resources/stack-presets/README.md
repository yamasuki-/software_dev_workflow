# Stack Presets — 言語/フレームワーク別スタックルールのプリセット集

このディレクトリは、`dev-workflow-overlay` の **2 層ルール** のうち **stack 層** (言語/フレームワーク共通) のひな型を、よく使うスタックごとに 1 セットずつ用意したもの。
プロジェクトの `.dev-workflow/rules/stack/` にコピーして、必要に応じて編集することで、その技術スタック向けの規約を一括で適用できる。

> 親ドキュメント: `~/.claude/skills/dev-workflow-overlay/resources/project-rules/README.md` (2 層ルール全体の説明)

## プリセット一覧

| プリセット名               | 想定スタック                                        | 主要ツール (テスト / DB / Lint)                         |
| -------------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| `python-fastapi`           | Python 3.13 + FastAPI 0.115 + SQLAlchemy 2 (async)  | pytest, pytest-asyncio, ruff, mypy --strict, uv         |
| `python-django`            | Python 3.13 + Django 5.x + DRF                      | pytest-django, factory-boy, ruff, mypy (django-stubs)   |
| `go-stdlib-chi`            | Go 1.23 + net/http + chi v5 + sqlc                  | go test -race, testify, testcontainers-go, golangci-lint|
| `typescript-nextjs`        | TypeScript 5.7 + Next.js 15 (App Router) + React 19 | Vitest または Jest, Playwright, ESLint, msw, Prisma     |
| `typescript-react-vite`    | TypeScript 5.7 + React 19 + Vite (SPA)              | Vitest または Jest, Playwright, TanStack Query, msw     |
| `react-native`             | TypeScript + React Native 0.76 + Expo SDK 52        | Jest (jest-expo), @testing-library/react-native, Maestro/Detox |
| `java-spring-boot`         | Java 21 + Spring Boot 3.4 + Spring Data JPA         | JUnit 5, AssertJ, Mockito, Testcontainers, Spotless, Flyway |
| `ruby-rails`               | Ruby 3.4 + Rails 8.x + Hotwire                      | RSpec, FactoryBot, Capybara + Cuprite, RuboCop, Brakeman, SimpleCov |

## 1 セットの中身 (9 ファイル)

各プリセットは以下のファイル構成で統一されている。
そのまま `.dev-workflow/rules/stack/` にコピーして使う。

```
<preset-name>/
├─ stack-config.md            ← 言語/FW/規約/CI (必ず読まれる)
├─ detailed-design.md         ← FW 固有の設計パターン
├─ test-implementation.md     ← テストランナー作法・フィクスチャ
├─ implementation.md          ← 言語慣習・エラー処理・パフォーマンス
├─ testing.md                 ← カバレッジ計測・E2E 実行
├─ implementation-review.md   ← 実装レビュー追加観点 (per_feature + cross)
├─ unit-test-review.md        ← 単体テスト結果レビュー追加観点 (per_feature + cross)
├─ integration-test-review.md ← 結合テスト結果レビュー追加観点
└─ e2e-test-review.md         ← E2E テスト結果レビュー追加観点
```

各ファイルは共通フォーマット (`ADD` / `OVERRIDE` / `DISABLE` / `ADDITIONAL_ARTIFACTS` / `REVIEW_EXTRAS`) に従う。
詳細は `project-rules/README.md` を参照。

## 使い方 (新規プロジェクトへの適用)

### Step 1: dev-workflow-overlay の 2 層ディレクトリを作る

PowerShell (Windows):

```powershell
$ProjectRoot = "$env:USERPROFILE\projects\my-app"
New-Item -ItemType Directory -Force -Path "$ProjectRoot\.dev-workflow\rules\stack"   | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectRoot\.dev-workflow\rules\project" | Out-Null
```

bash (macOS / Linux):

```bash
PROJECT_ROOT="$HOME/projects/my-app"
mkdir -p "$PROJECT_ROOT/.dev-workflow/rules/stack"
mkdir -p "$PROJECT_ROOT/.dev-workflow/rules/project"
```

### Step 2: プリセットを stack/ にコピー

`<preset-name>` をスタックに合わせて選び、配下のファイルを **すべて** `.dev-workflow/rules/stack/` にコピーする。

PowerShell:

```powershell
$Preset = "python-fastapi"   # ← 適用したいプリセット名に置換
$PresetDir = "$env:USERPROFILE\.claude\skills\dev-workflow-overlay\resources\stack-presets\$Preset"
Copy-Item "$PresetDir\*.md" "$ProjectRoot\.dev-workflow\rules\stack\"
```

bash:

```bash
PRESET="python-fastapi"
PRESET_DIR="$HOME/.claude/skills/dev-workflow-overlay/resources/stack-presets/$PRESET"
cp "$PRESET_DIR"/*.md "$PROJECT_ROOT/.dev-workflow/rules/stack/"
```

### Step 3: stack-config.md の値を埋める / 微調整

プリセットは **このスタックの一般的な前提** で書かれている。プロジェクトで具体化したい箇所 (DB ホスト名 / 環境変数名 / 独自の例外階層など) を書き換える。

特に確認すべき項目:

- 言語/FW のバージョン (LTS 別を採用する場合)
- DB / Redis / 外部サービスのバージョン
- フォーマッタ / リンタの設定
- CI の必須チェックの粒度
- カバレッジ目標 (プロジェクト要件で緩める/厳しくする)

### Step 4: project 層は別途用意

プロジェクト固有の事情 (ドメイン用語 / 内部 Slack 通知形式 / 監査ログ規約 など) は **project 層** (`.dev-workflow/rules/project/`) に書く。
テンプレは `project-rules/project-config.md` ほかをコピーして編集。

## TypeScript 系のテストランナー選定

`typescript-nextjs` / `typescript-react-vite` / `react-native` の `stack-config.md` は、テストランナーを **両論併記** している (Vitest / Jest)。
プロジェクトでどちらを採用するかは **project 層の `project-config.md`** に明記する:

```markdown
# project-config.md (抜粋)
## テストランナー選定
- 採用: Vitest
- 理由: Vite との統合が深く、起動速度が速い
- Jest からの差分: jest.config.ts は使わず vitest.config.ts に集約
```

`react-native` は Native module 解決の都合上、**Jest をスタック既定** として記述しているが、project 層で例外的に Vitest を選ぶことも禁止しない (project 層 OVERRIDE で明示)。

## 優先順位 (再掲)

`dev-workflow-overlay` の 2 層ルールにおける優先順位は以下の通り (高→低):

1. `project/<phase>.md` の `OVERRIDE` / `DISABLE`
2. `project/<phase>.md` の `ADD` / `ADDITIONAL_ARTIFACTS`
3. `stack/<phase>.md` (= 本プリセット) の `OVERRIDE` / `DISABLE`
4. `stack/<phase>.md` (= 本プリセット) の `ADD` / `ADDITIONAL_ARTIFACTS`
5. ベース `~/.claude/skills/<phase>/SKILL.md`

両層が `ADD` を出した場合は **両方とも適用**。
`OVERRIDE` / `DISABLE` が矛盾する場合は project が勝ち、その旨を `decisions.md` に記録する。

## カスタマイズの方針

プリセットは **叩き台** であり、コピー後に必ず以下を確認・編集することを推奨:

1. `stack-config.md` のバージョン / ツール選定をプロジェクト実態に合わせる
2. CI 必須チェック一覧をプロジェクトの GitHub Actions / GitLab CI に合わせて調整
3. カバレッジ目標を NFR に合わせて上書き
4. 不要な `ADD` / `OVERRIDE` は削除 (空セクションでも構わない)
5. 追加したいスタック由来ルールは `ADD` セクションに追記

スタックを跨いだ大きな変更 (例: ORM を Drizzle に変える) は、本ディレクトリのプリセット自体を編集するのではなく、**プロジェクト側でコピーしたファイルを編集** すること。プリセットはあくまで複数プロジェクトで共有される共通の出発点。

## 追加プリセットの作成

ここに無いスタックを使う場合 (例: ASP.NET Core, Kotlin Spring, Flutter):

1. 既存プリセットのうち最も近いものを丸ごとコピーし、別名のディレクトリに置く
2. 9 ファイルすべてをそのスタック向けに書き換える
3. 共通フォーマット (`ADD` / `OVERRIDE` / `DISABLE` / `ADDITIONAL_ARTIFACTS` / `REVIEW_EXTRAS`) は維持
4. 本 README の表に追記

## 関連ドキュメント

- `~/.claude/skills/dev-workflow-overlay/SKILL.md` — overlay スキルの概要
- `~/.claude/skills/dev-workflow-overlay/resources/project-rules/README.md` — 2 層ルールの全体構造とフォーマット
- `<REPO_ROOT>/README.md` — workflow 全体の README (legacy プロジェクトへの適用手順を含む)
- `<REPO_ROOT>/docs/workflow-overview.md` — フェーズ・レビュー・bug-fix の全体図
