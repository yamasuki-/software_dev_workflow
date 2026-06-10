# security-review — <stack 由来 / project 由来> rules

> セキュリティ専門レビュー (`security-review` Agent) に、スタック固有 / プロジェクト固有の観点を追加・上書きするためのオーバーレイ。
> 機械的に検出できるもの (依存脆弱性スキャン・SAST・シークレットスキャン) は `stack-config.md` の **自動チェック (MUST/SHOULD/MAY)** セクションにツールを宣言すれば auto-check が実行する。本ファイルは **LLM レビューで追加判定する観点** を書く。

## ADD
- (本フェーズのチェックに加算する観点があれば記述)

## OVERRIDE
- (ベースのセキュリティ観点のうち、このスタック/プロジェクトで読み替える項目があれば記述)

## DISABLE
- (該当しない観点を無効化する場合に記述。例: 「本プロジェクトはサーバを持たない静的サイトなので SQL インジェクション観点は対象外」)

## REVIEW_EXTRAS
- (security-review のチェックリストに追加する観点)

例 (スタック由来):
- [ ] (FastAPI) 依存性注入で認可を行う `Depends` が全保護ルートに付与されているか
- [ ] (Django) `@login_required` / `PermissionRequiredMixin` の付け漏れがないか、`DEBUG = False` か
- [ ] (Next.js) Server Action / Route Handler でユーザ入力が検証され、`dangerouslySetInnerHTML` の使用が正当か
- [ ] (Go) `database/sql` でプレースホルダを使い文字列連結クエリがないか
- [ ] (Rails) Strong Parameters の徹底、`html_safe` / `raw` の濫用がないか (Brakeman 警告と突き合わせ)

例 (プロジェクト由来):
- [ ] 自社の認可モデル (例: テナント分離) が全エンドポイントで適用されているか
- [ ] 監査ログ要件 (誰が・いつ・何を) が重要操作で満たされているか
- [ ] 取り扱う個人情報の保護要件 (マスキング/暗号化) が満たされているか

## 自動チェック連携 (参考)
依存脆弱性・SAST・シークレットスキャンは `stack-config.md` に宣言する。代表例:

| スタック | 依存脆弱性 | SAST | シークレット |
| -------- | ---------- | ---- | ------------ |
| Node/TS  | `npm audit` / `pnpm audit` | `eslint-plugin-security` / `semgrep` | `gitleaks` |
| Python   | `pip-audit` | `bandit` | `gitleaks` |
| Go       | `govulncheck` | `gosec` | `gitleaks` |
| Ruby     | `bundle audit` | `brakeman` | `gitleaks` |
| Java     | `dependency-check` | `spotbugs` (find-sec-bugs) | `gitleaks` |
