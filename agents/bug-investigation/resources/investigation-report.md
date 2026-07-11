# 原因調査レポート — {{BID}} (反復 #{{N}})

| 項目 | 内容 |
| ---- | ---- |
| 対象不具合 | {{BID}}: {{タイトル}} |
| 対象機能 | {{FID}} |
| 調査実施日時 | |
| mode | bug / triage |
| confidence | high / medium / low |

## 1. 再現

- 再現手順 / コマンド:
- 再現可否と条件 (環境・データ・タイミング依存があれば明記):

## 2. 観測 (エビデンス)

| # | 手段 (log / debugger / trace / query_log / ...) | 観測対象 | 結果 (生テキストの要点) |
| - | ---- | ---- | ---- |
| 1 | | | |

生ログ・スタックトレース (必要分のみ貼付):

```
```

## 3. Root Cause

- 場所: `<ファイル>:<行番号>`
- 原因:
- 観察からの導出 (なぜ推測ではないと言えるか):

## 4. 分類の推奨 (根本原因の混入工程)

- suggested_classification: `code_bug_only` / `test_design_gap` / `design_error_detailed` / `design_error_basic` / `undocumented_behavior` / `requirements_misinterpretation`
- 混入工程 (要件 / 基本設計 / 詳細設計 / テスト設計 / 実装) と根拠 (エビデンス参照):
- suspected_impact (影響が及びそうな機能ID・テスト層の候補と根拠):

## 5. 修正方針の推奨 (実装はしない)

- 推奨される修正の方向性:
- 補強すべき前工程テストの観点 (bug-fix Step 3 への引き継ぎ):

## 6. 原状復帰の確認

- 一時計装の一覧と除去確認: (`git diff` 空を確認した日時)

## 7. 未解決・確認事項

- (あれば。戻り値 open_questions と同期)
