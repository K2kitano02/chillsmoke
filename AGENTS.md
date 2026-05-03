# Repository Guidelines

## 自身の役割

- 本エージェントは Codex を主担当とし、ユーザーの依頼に応じて設計確認、実装、修正、テスト、レビュー、コミット、PR 作成まで行う。
- 作業時は Codex の `codex-general-dev` SKILL と `agent-workflows` SKILL、この `AGENTS.md`、`README.md`、`.codex/rules/` 配下の設計資料を併用する。
- 作業前に差分とブランチ状態を確認し、ユーザーの未関連変更を勝手に戻さない。
- 仕様の不整合は `.codex/rules/Plan.md`、`.codex/rules/ER.md`、`.codex/rules/TODO.md` と実装の差分として整理する。
- 実装レビューでは、再現手順・想定バグ・競合リスク（同時実行、重複、防御不足）を優先して確認する。
- 本エージェントは最終的な仕様決定権を持たず、判断が必要な場合は根拠と選択肢を示してユーザーに確認する。

## プロジェクトの前提

このリポジトリは、減煙支援アプリ「ChillSmoke」の Rails MVP を実装するためのプロジェクトです。作業前に必ず `.codex/rules/Plan.md`、`.codex/rules/ER.md`、`.codex/rules/TODO.md` を確認し、仕様・DB・Issue の整合性を崩さないでください。

## 構成

- `README.md`: サービス概要、想定ユーザー、MVP範囲。
- `.codex/CODEX.md`: Codex 向けの詳細な作業ガイド。
- `.codex/agents/`: `agent-workflows` SKILL を使うときの Planner / Test Writer / Generator / Evaluator 別ガイド。
- `.codex/rules/Plan.md`: MVP仕様、画面、ルーティング、実装順。
- `.codex/rules/ER.md`: 正とするDB設計。
- `.codex/rules/TODO.md`: Issue 単位の実装手順。
- `.github/ISSUE_TEMPLATE/`: GitHub Issue テンプレート。`.github/` は Git 管理対象です。

Rails 標準構成の `app/`、`config/`、`db/migrate/`、`test/` または `spec/` を使います。

## 開発コマンド

このプロジェクトは Docker 環境で開発・検証します。Rails、テスト、lint、DB 操作などのコマンドは原則としてホスト直実行ではなく Docker 経由で実行してください。

- `docker compose up`: Docker の web/db 起動。
- `docker compose run --rm web bin/rails db:create db:migrate`: PostgreSQL 作成・マイグレーション。
- `docker compose run --rm web bin/rails test`: テスト実行。
- `docker compose run --rm web bundle exec rubocop`: RuboCop 実行。
- `docker compose run --rm web bin/brakeman --no-pager`: Brakeman 実行。

## 開発フロー

- 通常の開発作業は `agent-workflows` SKILL に従い、目的確認、設計整理、テスト方針、実装、評価を分けて進める。
- 要件が広い、曖昧、または画面・仕様に影響する場合は Planner として受け入れ条件と作業単位を整理する。
- 金額計算、snapshot、継続日数、同時実行、DB 制約、ユーザーフローに関わる変更では、実装前または実装中に Test Writer の観点で期待動作を明確にする。
- 具体的な Issue、仕様、バグ、レビュー指摘がある場合は Generator として、最小の一貫した差分で実装する。
- 実装後は Evaluator として、Docker 経由のテスト、lint、必要に応じた MCP/Playwright 確認、差分確認を行う。
- Git 操作、ブランチ、コミット、PR、main 最新化は `codex-general-dev` SKILL の手順に従う。

## デプロイ・動作確認

- 本番URL: https://chillsmoke.onrender.com/
- MCP/Playwright などでデプロイ後の挙動確認が必要な場合は、この本番URLを参照する。

## 実装上の重要ルール

- 認証は Devise、DB は PostgreSQL、UI は Tailwind 前提です。
- `config.time_zone = "Tokyo"` を設定し、日付判定は `Time.zone.today` を使います。
- `user_smoking_logs` は `user_id, smoked_on` で一意、snapshot 5項目を新規作成時だけコピーします。
- ダッシュボードや日付詳細の GET だけで喫煙ログを作成しません。保存操作時のみ作成します。
- `+1` 加算は `with_lock` や atomic update で加算漏れを防ぎます。
- 継続日数は当日を含めず、未記録日または未達日で止めます。
- 累計節約額と残高は昨日までの確定分のみを使い、今日分は見込みとして別表示します。
- 購入履歴は取得済みの `wishlist` 経由で作成し、購入処理は transaction とロックで二重購入を防ぎます。

## 命名・スタイル

Rails 標準に従います。Model は `UserSmokingLog` のような単数 PascalCase、テーブルは `user_smoking_logs` のような複数 snake_case、Controller は `UserSmokingLogsController` のような複数形にします。Ruby、ERB、YAML、Markdown は 2 スペースインデントを使います。

## テスト方針

金額、snapshot、継続日数、同時実行、重複防止は優先してテストします。特に、表示だけでログが作られないこと、snapshot が既存更新で変わらないこと、鬼モード計算、未記録日での継続停止、購入残高チェックを確認してください。

## コミット・Pull Request

既存履歴に合わせ、`add: ER図` のように短く内容が分かるメッセージにします。PR には要約、関連 Issue、UI 変更時のスクリーンショット、schema 変更の説明、テスト結果または未実行理由を含めてください。

## 応答言語

- ユーザーへの説明、進捗共有、レビュー結果、最終回答は原則として日本語で行う。
- ユーザーが明示的に英語を要求した場合のみ英語で返答する。
- コード、識別子、ライブラリ名、エラーメッセージ原文が必要な場合は、その箇所のみ英語を保持してよい。

## セキュリティ・管理

secret、credential、ローカル環境ファイルはコミットしません。`.codex/` と `.github/` は設計・運用上の共有対象なので ignore しないでください。
