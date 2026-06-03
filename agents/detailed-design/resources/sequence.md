# 処理シーケンス — {{機能ID}} {{機能名}}

> 主要なユースケースごとに1つシーケンス図を作成する。
> 正常系だけでなく、代表的な異常系も必ず1つ以上記述する。

## 1. ユースケース一覧

| ID | ユースケース名 | アクター | 概要 |
| -- | -------------- | -------- | ---- |
| UC01 |              |          |      |

## 2. シーケンス図

### UC01 — 正常系

```mermaid
sequenceDiagram
    actor U as ユーザ
    participant FE as フロントエンド
    participant API as バックエンドAPI
    participant DB as データストア

    U->>FE: 操作
    FE->>API: リクエスト
    API->>DB: クエリ
    DB-->>API: 結果
    API-->>FE: レスポンス
    FE-->>U: 表示
```

### UC01 — 異常系 (バリデーション失敗)

```mermaid
sequenceDiagram
    actor U as ユーザ
    participant FE as フロントエンド
    participant API as バックエンドAPI

    U->>FE: 不正な入力
    FE->>API: リクエスト
    API-->>FE: 400 (エラー詳細)
    FE-->>U: エラーメッセージ表示
```

## 3. 補足
- リトライ・冪等性・タイムアウトに関する考慮事項。
- トランザクション境界。
