# testing — Ruby on Rails rules

## ADD
- カバレッジ: SimpleCov (branch coverage 有効)
  - スタック既定目標: 行 85% / 分岐 75%
  - exclude: `config/`, `db/`, `bin/`, `spec/` (デフォルト)
- E2E: system spec (Capybara + Cuprite)
  - CI で headless 実行
  - 主要 flow を network 込みで通す
- DB:
  - 通常 spec は transactional fixtures
  - system spec は truncation
- 外部 HTTP: WebMock で実通信を block、VCR cassette で再生
- 並列実行: `parallel_tests` または RSpec `--profile` で slow test を可視化
- 実行方法:
  - `bundle exec rspec` → 全 spec
  - `bundle exec rspec spec/system` → system spec のみ
  - `bundle exec rake coverage` (SimpleCov を bin/rake task で叩く)
- テスト結果は `docs/04_test_results/<FID>/` に Markdown で残す
  - RSpec の `--format json` / `--format html` を artifact 化
  - SimpleCov の `coverage/index.html` を添付参照

## OVERRIDE
- 「テスト未実施 / 実施不可は理由」→ RSpec の `skip "理由"` / `pending "理由"` の文字列を結果に転記

## DISABLE
- なし

## ADDITIONAL_ARTIFACTS
- `docs/04_test_results/<FID>/coverage.html` (SimpleCov)
- `docs/04_test_results/<FID>/rspec.html` または junit.xml

## REVIEW_EXTRAS
- カバレッジが目標を満たすか
- system spec が主要 flow を網羅
- VCR cassette が更新時に意図せぬ通信を保存していないか
- slow test の上位 N 件が許容内か (`--profile=10`)
- flaky テスト (Capybara timing / Cuprite まわり) がないか
- skip / pending に理由があるか
- factory_bot のレコード生成数が肥大していないか (`create` を `build` に置換可能か)
