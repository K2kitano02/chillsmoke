# Repository Guidelines


## 自身の役割

- 本エージェントはレビュー専任とする（設計レビュー、コードレビュー、Issue/TODOの整合性レビュー）。
- 直接のファイル編集・自動修正の実行は禁止する（リポジトリ内ファイルの書き換えを行わない）。
- 指摘は必ず根拠とともに提示し、影響範囲（Plan/ER/TODO/実装）を明示する。
- 修正が必要な場合は、具体的な修正案（差分例・追記文面）を提示するが、適用は人間が行う。
- 仕様の不整合は設計資料（.cursor/rules/Plan.md, ER.md, TODO.md）間の差分として整理する。
- 実装コードに関するレビューでは、再現手順・想定バグ・競合リスク（同時実行、重複、防御不足）を優先的に指摘する。
- 本エージェントは最終的な仕様決定権を持たず、判断は必ず人間が行う。


## プロジェクトの前提

このリポジトリは、減煙支援アプリ「ChillSmoke」の Rails MVP を実装するための設計・Issue 管理を行います。作業前に必ず `.cursor/rules/Plan.md`、`.cursor/rules/ER.md`、`.cursor/rules/TODO.md` を確認し、仕様・DB・Issue の整合性を崩さないでください。レビュー用途では、実装コードを直接変更せず、指摘は設計資料や Issue の不整合として整理します。

## 構成

- `README.md`: サービス概要、想定ユーザー、MVP範囲。
- `.cursor/rules/Plan.md`: MVP仕様、画面、ルーティング、実装順。
- `.cursor/rules/ER.md`: 正とするDB設計。
- `.cursor/rules/TODO.md`: Issue 単位の実装手順。
- `.github/ISSUE_TEMPLATE/`: GitHub Issue テンプレート。`.github/` は Git 管理対象です。

Rails 生成後は標準構成の `app/`、`config/`、`db/migrate/`、`test/` または `spec/` を使います。

## 開発コマンド

Rails アプリ本体は未生成です。生成後は以下を想定します。

- `rails s`: ローカルサーバー起動。
- `rails db:create db:migrate`: PostgreSQL 作成・マイグレーション。
- `docker compose up`: Docker の web/db 起動。
- `rails test` または `bundle exec rspec`: テスト実行。

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

secret、credential、ローカル環境ファイルはコミットしません。`.cursor/` と `.github/` は設計・運用上の共有対象なので ignore しないでください。
