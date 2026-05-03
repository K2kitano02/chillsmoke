# CLAUDE.md

このファイルは Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## コミュニケーション

- ユーザーへの説明・質問・確認はすべて**日本語**で行う。
- コマンドやツールを実行する前に、「何をするか」「なぜするか」を日本語で簡潔に説明する。
  - 例: 「テストを実行して、変更が既存機能を壊していないか確認します」
  - 例: 「feature/42 ブランチを main から切ります」

## プロジェクト概要

**ChillSmoke** は、禁煙ではなく「減煙」を支援するアプリ。Rails 7.2 + Devise + PostgreSQL + Tailwind CSS で構築。ユーザーは喫煙本数を記録し、減らせた分を金額として可視化し、欲しいものの購入に向けた貯金として実感できる。

基本思想: 完全禁煙を強制せず、少しずつ減らした成果を「使える価値」として見せることで継続を支える。

### 技術スタック
- Ruby 3.3.6 / Rails 7.2.1 / PostgreSQL 17
- Tailwind CSS / Hotwire (Turbo + Stimulus) / esbuild
- Devise 認証 / simple_calendar gem
- Minitest（model, controller, service, integration, system テスト）
- CI: GitHub Actions（Brakeman + RuboCop + テストスイート）
- デプロイ: Render（Web）+ Neon（DB）/ 本番URL: https://chillsmoke.onrender.com/
- 開発環境: Docker Compose

## 授業形式モード

`chillsmoke-core.mdc` のルールにより、機能実装時は**講義形式の3フェーズ構造**で進める:
1. **フェーズ1（講義）**: このステップで何を作るか、アプリ全体のどこに位置するかを説明。図・比較表・Before/After を使い、全体像 → ファイル → メソッドへ段階的にズームイン。

ユーザーの学習機会を守るため、新機能の実装時はこの形式に従うこと。

## よく使うコマンド

```bash
# Docker で起動（localhost:3000）
docker compose up

# ローカル起動（PostgreSQL が動いている前提）
./bin/dev                            # Web + JS/CSS ウォッチャー（Procfile.dev）

# テスト全体（CI と同じ）
bin/rails db:test:prepare test test:system

# テスト個別実行
bin/rails test                                    # ユニットテスト全体
bin/rails test:system                             # システムテストのみ
bin/rails test test/models/user_smoking_log_test.rb   # ファイル単位
bin/rails test test/models/user_smoking_log_test.rb -n test_snapshot_attributes_from_user_setting  # メソッド単位
bin/rails test test/services/                     # ディレクトリ単位

# Lint・セキュリティ
bundle exec rubocop                  # RuboCop（Omakase スタイル）
bundle exec rubocop -A               # 自動修正
bin/brakeman --no-pager              # セキュリティスキャン

# データベース
rails db:create db:migrate
rails db:rollback STEP=1
```

## アーキテクチャ

### 設計ドキュメント優先順位（chillsmoke-core.mdc より）
仕様が曖昧な場合、この順で参照する:
1. `.claude/rules/Plan.md` — MVP 全体仕様、ルーティング、実装順
2. `.claude/rules/ER.md` — DB スキーマ（DBDiagram 形式、正本）
3. `.claude/rules/TODO.md` — ISSUE ごとのチェックリスト・受け入れ条件

### TODO.md の運用ルール
- ISSUE の実装が完了したら、「やること」「ゴール」のチェックリスト部分を `<!-- 実装クリア: ISSUE-NN ... -->` で**コメントアウト**する。
- 既存の完了済み ISSUE のコメントアウト形式に従うこと。

### 現在のデータベース構造（3テーブル）

```
User（Devise）
├── has_one  :user_setting       （1:1、user_id にユニークインデックス）
└── has_many :user_smoking_logs  （1:多）

UserSetting
├── target_daily_cigarette_count    （目標本数）
├── baseline_daily_cigarette_count  （基準本数、節約額計算の基準）
├── pack_price, cigarettes_per_pack （タバコ代の計算用）
└── is_oni_mode                     （鬼モード: 目標超過で節約額ゼロ）

UserSmokingLog（1ユーザー1日1レコード、[user_id, smoked_on] にユニークインデックス）
├── smoked_on: date
├── smoking_count: integer
└── snapshot 5カラム（作成時の UserSetting を凍結コピー）:
    target_daily_cigarette_count_snapshot, baseline_daily_cigarette_count_snapshot,
    pack_price_snapshot, cigarettes_per_pack_snapshot, is_oni_mode_snapshot
```

注意: `UserSchedule`、`UserScheduleReflection`、`UserWishlist`、`UserPurchaseHistory` は Plan.md/ER.md に設計済みだが、**まだ未実装**（モデルファイル・DBテーブルなし）。

### コアサービス: `SmokingLog::Today`（`app/services/smoking_log/today.rb`）

表示と永続化の分離を担うサービス:

- **`SmokingLog::Today.for_display(user)`** — DB レコードまたは未保存の仮想オブジェクトを返す。GET エンドポイント（ダッシュボード）で使用。DBへの INSERT は行わない。
- **`SmokingLog::Today.find_or_create_persisted!(user)`** — 当日ログがなければ作成（作成時に snapshot をコピー）。保存操作専用。
- **`SmokingLog::Today.increment_persisted!(user)`** — アトミック +1: transaction → find_or_create → `with_lock` → `increment!(:smoking_count)`。作成時の競合は SAVEPOINT + rescue/retry で対応。

### リクエストフロー

```
GET /dashboard → DashboardController#index
  → SmokingLog::Today.for_display(current_user)  [DB INSERT なし]

POST /today_smoking_log/increment → UserSmokingLogsController#increment_today
  → SmokingLog::Today.increment_persisted!(current_user)  [アトミックトランザクション]

GET/POST /user_smoking_logs/* → UserSmokingLogsController
  → new/edit: フォーム表示のみ（DB INSERT なし）
  → create: find_or_initialize_by(smoked_on)、新規なら snapshot 適用、保存
  → update: smoking_count のみ更新、snapshot は変更しない

GET /user_smoking_logs/by_date?date=YYYY-MM-DD → 日付別詳細
  → find_by(smoked_on:) または nil。未記録なら「—」表示

GET /calendar → CalendarController#index
  → simple_calendar で色分け表示（緑=目標達成、赤=超過）
```

## 重要な実装ルール

`chillsmoke-core.mdc` に基づくアーキテクチャ違反防止ルール:

### Snapshot パターン
- snapshot 5フィールドは**新規ログ作成時のみ**コピー。更新時はコピーしない
- コピー元は保存時点の `current_user.user_setting`
- 過去日の値を現在の UserSetting で再計算しない

### ログ作成は保存操作時のみ
- GET/表示リクエストでは**絶対に**ログを作成しない — 表示には未保存の仮想オブジェクトを使う
- ログ作成が許可される操作: +1記録、手動フォーム保存、スケジュール反映

### アトミック +1 記録
- `with_lock` + `increment!` をトランザクション内で使用する
- `smoking_count += 1; save!` は禁止
- 作成時の競合は `requires_new: true` の SAVEPOINT + rescue/retry で対応

### 累計節約額 = 昨日まで
- 累計: `smoked_on < Time.zone.today` のログの `saved_yen` 合計
- 当日は「見込み」として別枠表示、残高には含めない

### 継続日数（ストリーク）
- 当日は継続日数に含めない
- 昨日から1日ずつ遡り、未記録または未達成の日で終了
- 未記録日をスキップして飛び飛びでカウントしない

### 鬼モード
- 判定には `is_oni_mode_snapshot`（現在の設定ではなく）を使用
- `smoking_count > target_snapshot` なら `saved_cigs = 0`

### スコープとセキュリティ
- すべてのクエリは `current_user` スコープ — `Model.find(params[:id])` は禁止

### 未記録日の表示
- 未記録日は「—」表示。現在の UserSetting の値で補完しない

### 日付境界
- 常に `Time.zone.today`（東京タイムゾーン）を使用 — `Date.today` や `Time.now.to_date` は禁止

## コードスタイル

- **Omakase Ruby スタイル**（`rubocop-rails-omakase` gem）
- **UI テキスト**: 日本語 / **コード・コメント**: 英語
- **Git ブランチ**: `feature/NN` → main への PR（NN は TODO.md の ISSUE 番号）

## CI/CD

GitHub Actions（`.github/workflows/ci.yml`）が PR・main プッシュ時に実行:
1. `scan_ruby`: Brakeman セキュリティスキャン
2. `lint`: RuboCop
3. `test`: PostgreSQL サービス付きフルテスト（`bin/rails db:test:prepare test test:system`）

デプロイ: main ブランチ → Render（Web）、Neon（DB）。本番URL: https://chillsmoke.onrender.com/ 。ヘルスチェック: `GET /up`

MCP/Playwright などでデプロイ後の挙動確認が必要な場合は、本番URLを参照する。

## Git ブランチ運用

新しい作業を始めるとき:

```sh
git switch main
git pull --ff-only
git switch -c feature/NN
```

ルール:

- 作業前に `main` を最新化する。
- ブランチ名は `feature/NN`（NN = TODO.md の ISSUE 番号、例: `feature/42`, `feature/50`）。
- バグ修正の場合は `fix/NN`。

## Dirty Worktree Rule

作業ツリーに差分がある場合:

```sh
git status --short --branch
git diff --stat
```

判断:

- 自分の作業に関係ある差分なら、内容を読んでから進める。
- 関係ない差分なら、触らずに残す。
- ユーザーの差分を勝手に戻さない。
- `git reset --hard` や `git checkout --` は、明示指示がない限り使わない。

## Implementation Workflow

実装前:

- 目的を短く説明する。
- 触る予定のファイルを伝える。
- 既存パターンを確認する。

実装中:

- 変更範囲を小さく保つ。
- 既存の命名、型、ディレクトリ構成に合わせる。
- 関係ないリファクタを混ぜない。

実装後:

```sh
git diff --stat
git diff
```

確認すること:

- 意図したファイルだけ変わっているか。
- 不要な生成物が混ざっていないか。
- 仕様外の機能追加が入っていないか。
