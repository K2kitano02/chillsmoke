# CODEX.md

このファイルは Codex が ChillSmoke で作業するときの詳細ガイドです。入口の絶対ルールは `AGENTS.md`、仕様の正本は `.codex/rules/`、役割別フローは `.codex/agents/` を参照します。

## 参照順

作業前に、目的に応じて以下を確認します。

1. `AGENTS.md`: Codex の役割、Docker 必須、SKILL 利用、PR 方針。
2. `README.md`: サービス概要、MVP 範囲、デプロイ情報。
3. `.codex/rules/Plan.md`: MVP 仕様、画面、ルーティング、実装順。
4. `.codex/rules/ER.md`: DB 設計の正本。
5. `.codex/rules/TODO.md`: Issue ごとの作業内容と完了条件。
6. `.codex/rules/chillsmoke-core.md`: 事故防止の実装ルール。
7. `.codex/agents/`: `agent-workflows` SKILL の役割別ガイド。

## 開発フロー

通常開発では `agent-workflows` SKILL を使い、必要に応じて役割を切り替えます。

- Planner: 依頼が広い、曖昧、または仕様影響が大きい場合に、受け入れ条件と作業単位を整理する。
- Test Writer: 金額、snapshot、継続日数、同時実行、DB 制約、画面遷移など、壊れやすい振る舞いの期待値を明確にする。
- Generator: 具体的な Issue、仕様、バグ、レビュー指摘に対して、最小の一貫した差分で実装する。
- Evaluator: 実装後に Docker 経由のテスト、lint、必要な MCP/Playwright 確認、差分確認を行う。

Git 操作、ブランチ作成、コミット、push、PR 作成は `codex-general-dev` SKILL の手順に従います。

## よく使うコマンド

このプロジェクトは Docker 環境で検証します。Rails、テスト、lint、DB 操作は原則としてホスト直実行しません。

```bash
# Docker で起動（localhost:3000）
docker compose up

# テスト全体（CI と同じ）
docker compose run --rm web bin/rails db:test:prepare test test:system

# テスト個別実行
docker compose run --rm web bin/rails test
docker compose run --rm web bin/rails test:system
docker compose run --rm web bin/rails test test/models/user_smoking_log_test.rb
docker compose run --rm web bin/rails test test/services/

# Lint・セキュリティ
docker compose run --rm web bundle exec rubocop
docker compose run --rm web bundle exec rubocop -A
docker compose run --rm web bin/brakeman --no-pager

# データベース
docker compose run --rm web bin/rails db:create db:migrate
docker compose run --rm web bin/rails db:rollback STEP=1
```

## 実装時の要点

詳細は `.codex/rules/chillsmoke-core.md` を正として扱います。ここでは作業中に特に見落としやすい点だけを再掲します。

- 日付判定は `Time.zone.today` を使う。
- GET 表示だけで `user_smoking_logs` を作成しない。
- snapshot 5項目は新規ログ作成時だけコピーする。
- 過去ログの金額計算は現在設定ではなく snapshot に基づける。
- `+1` 加算や購入処理は transaction、lock、atomic update を使う。
- ユーザー所有データは必ず `current_user` 配下から取得する。

## TODO 運用

- Issue 実装時は `.codex/rules/TODO.md` の対象 Issue と受け入れ条件を確認する。
- Issue 完了時は、既存形式に合わせて該当チェックリストを `<!-- 実装クリア: ISSUE-NN ... -->` でコメントアウトする。
- 仕様に迷ったら `.codex/rules/Plan.md`、DB に迷ったら `.codex/rules/ER.md`、事故防止ルールは `.codex/rules/chillsmoke-core.md` を優先する。

## CI/CD・本番確認

- CI: GitHub Actions で Brakeman、RuboCop、テストスイートを実行。
- デプロイ: main ブランチから Render（Web）+ Neon（DB）。
- 本番URL: https://chillsmoke.onrender.com/
- ヘルスチェック: `GET /up`
- MCP/Playwright などでデプロイ後の挙動確認が必要な場合は、本番URLを参照する。

## 応答・説明

- ユーザーへの説明、進捗共有、レビュー結果、最終回答は日本語で行う。
- Issue 実装や新機能実装では、`.codex/rules/chillsmoke-core.md` の「講座式・コード解説重視」ルールに従う。
- 説明は責務や設計の抽象論に寄せすぎず、Ruby / Rails 初学者向けに、実際のコード行・メソッド・構文の意味を噛み砕く。
