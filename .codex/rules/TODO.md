# ISSUE-00 Rails新規作成（Tailwindまで）

## なぜ必要か

- 以降のすべての実装（Devise/CRUD/画面）を載せる土台を先に作るため
- 「画面が表示できる状態」を最速で作り、以後のPRを小さく回すため

## 必要なこと(簡易的に)

- Ruby/Railsの実行環境がある（ローカル or DockerはISSUE-01で整備）
- DBはPostgreSQL想定（`rails new`時の指定を揃える）

## やること(コードレベル)

- **変更点（ファイル）**: `Gemfile` / `config/*` / `app/views/layouts/application.html.erb` / `app/assets/stylesheets/*`
<!-- 実装クリア: ISSUE-00
- [ ] `rails new`（DB=postgres）
- [ ] **`config/application.rb` に `config.time_zone = "Tokyo"`** を設定する
      　（`Time.zone.today` を基準とした **`user_smoking_logs.smoked_on`** やスケジュール反映の `reflected_on` など、アプリ内の日付境界の基準）
- [ ] Tailwind導入（`tailwindcss-rails` 等、採用方針に合わせる）
- [ ] ルート（`root`）を仮ページへ（例: `HomeController#index`）(ISSUE-02参照)
- [ ] `application` レイアウトに最低限のコンテナ/ヘッダー枠を作る
      -->

## ゴール

<!-- 実装クリア: ISSUE-00
- [ ] `rails s` でトップページが表示され、Tailwindのクラスが効いている
- [ ] **タイムゾーンが Tokyo で明示されている**（上記 `config.time_zone`）
-->

---

# ISSUE-01 Docker開発環境（PostgreSQL含む）

## なぜ必要か

- 環境差分（Ruby/PG/Node等）による詰まりを減らし、実装/レビューを安定させるため

## 必要なこと(簡易的に)

- ISSUE-00のアプリ雛形がある

## やること(コードレベル)

- **変更点（ファイル）**: `Dockerfile` / `compose.yaml(or docker-compose.yml)` / `config/database.yml`
<!-- 実装クリア: ISSUE-01
- [ ] webコンテナ、dbコンテナ（PostgreSQL）を定義
- [ ] DB接続情報を環境変数化
- [ ] ボリューム（db永続化）設定
      -->
- [ ] 初回手順をREADMEに追記（必要なら）

## ゴール

<!-- 実装クリア: ISSUE-01
- [ ] `docker compose up` でWeb+DBが起動し、`docker compose run --rm web bin/rails db:create db:migrate` が成功する
-->

---

# ISSUE-02 テストページの作成

## なぜ必要か

- ISSUE-00 ~ 01 までの動作確認のため

## 必要なこと(簡易的に)

- **ISSUE-00 完了**（`rails new`・Tailwind・**`root` を仮ページへ向ける**記述まで。画面の実体は本 ISSUE で用意する）
- Docker で起動確認する場合は **ISSUE-01 完了**（任意）

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/home_controller.rb` / `app/views/home/index.html.erb`
<!-- 実装クリア: ISSUE-02
- [ ] **`HomeController`（または同等）**を追加し **`index`** を定義する
- [ ] **`app/views/home/index.html.erb`** に仮の見出し・文言を置き、**Tailwind のクラスが効く**ことを確認できるようにする
- [ ] **`config/routes.rb` の `root`** が **`home#index`**（上記コントローラ）を指すよう **ISSUE-00 で置いた `root` の方針と一致**させる
      -->

## ゴール

<!-- 実装クリア: ISSUE-02
- [ ] `rails s` 起動後、**`/`（root）** にアクセスすると仮ページが表示され、ISSUE-00 の「トップが表示される」と整合する
-->

---

# ISSUE-03 デプロイ

## なぜ必要か

- 早期にデプロイすることで環境によるバグの早期発見を可能とするため

## 必要なこと

- RenderとNeon(db)を連携しデプロイする方法を調べる

## やること

<!-- 実装クリア: ISSUE-03
- [ ] 調べたことを実行する
-->

## ゴール

<!-- 実装クリア: ISSUE-03
デプロイが完了し、ISSUE-02で設定した仮ページがインターネット上で表示されること
本番URL: https://chillsmoke.onrender.com/
-->

---

# ISSUE-10 Devise導入（User作成・登録/ログイン/ログアウト）

## なぜ必要か

- ユーザーごとに喫煙ログ/設定/ウィッシュリストを紐づけるために、先に認証基盤が必要

## 必要なこと(簡易的に)

- ISSUE-00（できればISSUE-01も）完了

## やること(コードレベル)

- **変更点（ファイル）**: `Gemfile` / `config/routes.rb` / `app/models/user.rb` / `db/migrate/*` / `config/initializers/devise.rb`
<!-- 実装クリア: ISSUE-10
- [ ] `devise` を追加し、`rails g devise:install`
- [ ] `rails g devise User`（`email`, `encrypted_password`, `reset_password_*`, `remember_created_at` など）
- [ ] `User` に `name` を追加（migration）し、登録フォームへ反映
- [ ] `config.action_mailer.default_url_options` を開発用に設定
      -->

## ゴール

<!-- 実装クリア: ISSUE-10
- [ ] 新規登録→ログイン→ログアウトがUIで確認できる
-->

---

# ISSUE-11 保護ページのログイン必須化

## なぜ必要か

- 「ログインユーザーのデータだけを扱う」前提を保護ページに適用し、以降の実装を簡単にするため
- ただし `root("/")` はアプリ説明画面・オンボーディングとして未ログインでも閲覧可能とする

## 必要なこと(簡易的に)

- ISSUE-10完了

## やること(コードレベル)

- **変更点（ファイル）**: `app/controllers/application_controller.rb` / 各controller
<!-- 実装クリア: ISSUE-11
- [ ] `before_action :authenticate_user!` を適用（`root("/")` の説明画面など、意図した公開ページは除外）
- [ ] ログイン後の遷移先（`after_sign_in_path_for`）を決める（ダッシュボード等）
      -->

## ゴール

<!-- 実装クリア: ISSUE-11
- [ ] 未ログインで保護ページへアクセスするとログインへリダイレクトされる
- [ ] `root("/")` は未ログインでも閲覧できる説明画面として扱う
-->

---

# ISSUE-20 UserSettingテーブル/モデル作成

## なぜ必要か

- 目標本数/基準本数/箱価格などが、ログ作成・節約計算・表示の前提データになるため

## 必要なこと(簡易的に)

- ISSUE-10完了（Userが必要）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_setting.rb` / `app/models/user.rb`
<!-- 実装クリア: ISSUE-20
- [x] migration作成（`user:references{unique}`, `baseline_daily_cigarette_count`, `target_daily_cigarette_count`, `pack_price`, `cigarettes_per_pack default:20`, `is_oni_mode default:false`）
- [x] `User has_one :user_setting, dependent: :destroy`
- [x] `UserSetting belongs_to :user`
- [x] バリデーション（数値・`baseline >= target`）
- [x] DB制約（unique index on `user_id`）
      -->

## ゴール

<!-- 実装クリア: ISSUE-20
- [x] consoleで作成でき、同一userに2件目が作れない（DB/validationのいずれかで防止）
-->

---

# ISSUE-21 初回導線（設定未作成なら初期設定へリダイレクト）

## なぜ必要か

- 以降の画面/計算で `current_user.user_setting` を前提にできるようにするため（nil分岐を減らす）

## 必要なこと(簡易的に)

- ISSUE-20完了（UserSettingが存在）

## やること(コードレベル)

- **変更点（ファイル）**: `app/controllers/application_controller.rb` / `config/routes.rb`
<!-- 実装クリア: ISSUE-21
- [x] `current_user.user_setting.present?` をチェックする `before_action`
- [x] 初期設定作成ページのみはリダイレクト対象外にする
- [x] ルート/遷移（ダッシュボード→設定へ、など）を確定
      -->

## ゴール

<!-- 実装クリア: ISSUE-21
- [x] 新規登録直後に初期設定画面へ誘導される
- [x] ログイン成功後: **未設定**は `new_user_setting_path`、**設定済み**は `stored_location` 若しくは `dashboard_path`（`ApplicationController#after_sign_in_path_for`）
- [x] 保護ページ: `UserSetting` なしのときは `ensure_user_setting_exists` で `new_user_setting_path` へ（`user_settings#new` / `#create` だけ `skip` してループ防止）
-->

## 導線の固定方針（Plan.md 整合・再発防止）

- **`root`（`/`）**: 未ログイン向けオンボーディング（`Plan.md`）。ログイン後の「ホーム」**ではない**。
- **未設定ユーザー**: サインイン直後・保護ルート遷移ともに、まず**初期設定**（`user_settings#new`）へ。`root` に逃がさない。
- **設定済みユーザー**: サインイン直後のデフォルトは **`dashboard_path`**。初期設定**保存直後**も同じ（ISSUE-22 ゴールと一致）。
- 上記を変更する場合は **`Plan.md` の画面定義**と、`after_sign_in_path_for` ・ `ensure_user_setting_exists` ・ `UserSettingsController#create` の `redirect_to` を**一括で**見直すこと。

---

# ISSUE-22 初期設定「作成」画面（UserSetting create）

## なぜ必要か

- ユーザーが初回に必要情報を入力できないと、ログ/計算が成立しないため

## 必要なこと(簡易的に)

- ISSUE-20/21完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_settings_controller.rb` / `app/views/user_settings/new.html.erb` / `app/controllers/dashboard_controller.rb`（遷移先のスケルトン・Plan.md 整合）
- `app/controllers/application_controller.rb`（`after_sign_in_path_for` を `dashboard_path` に）
<!-- 実装クリア: ISSUE-22
- [x] `resource :user_setting, only: [:new, :create]` を定義（`edit`/`update` は ISSUE-23）
- [x] `get dashboard` + `DashboardController#index`（表示の本実装は ISSUE-53）
- [x] `new/create` を実装（`current_user.build_user_setting`）
- [x] strong params（`user_setting_params`）
- [x] バリデーションエラー表示（`new` 再表示 + `status: :unprocessable_entity`）
- [x] 既存設定者の new/create 直打ちは `redirect_if_user_setting_exists`（ISSUE-21 の `skip`/`ensure` と整合）
      -->

## ゴール

<!-- 実装クリア: ISSUE-22
- [x] 初期設定を保存すると `dashboard_path`（Plan.md のダッシュボード。スケルトンは本 Issue、中身は ISSUE-53 以降）へ遷移する
-->

---

# ISSUE-23 設定「編集」画面（UserSetting update）

## なぜ必要か
- 目標や価格は運用中に変わるため、編集導線がないと継続利用できないため

## 必要なこと(簡易的に)

- ISSUE-22完了

## やること(コードレベル)

- **変更点（ファイル）**: `app/controllers/user_settings_controller.rb` / `app/views/user_settings/edit.html.erb`
<!-- 実装クリア: ISSUE-23
- [x] `edit/update` 実装（本人の設定のみ）
- [x] is_oni_mode のON/OFF入力（checkbox等）
      -->

## ゴール

<!-- 実装クリア: ISSUE-23
- [x] 変更が保存され、以降の表示/計算に反映される
-->

---

# ISSUE-30 UserSmokingLogテーブル/モデル作成（1日1件+snapshot）

## なぜ必要か

- MVPの中核である「日次の喫煙本数」を保持し、履歴/集計/カレンダー表示の基礎にするため
- snapshotで当日の計算再現性（後から設定変更しても当日分が壊れない）を担保するため

## 必要なこと(簡易的に)

- ISSUE-10（User）完了
- snapshotコピー元としてISSUE-20（UserSetting）があるとスムーズ

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_smoking_log.rb` / `app/models/user.rb`
<!-- 実装クリア: ISSUE-30
- [x] migration（`user:references`, `smoked_on:date`, `smoking_count default:0`, snapshots **5つ**、index unique）
  - [x] `target_daily_cigarette_count_snapshot`
  - [x] `baseline_daily_cigarette_count_snapshot`
  - [x] `pack_price_snapshot`
  - [x] `cigarettes_per_pack_snapshot`（箱本数も変更され得るため）
  - [x] `is_oni_mode_snapshot`（鬼モードON/OFFも当日の計算再現に必要）
- [x] `UserSmokingLog` に `belongs_to :user`
- [x] `User` に `has_many :user_smoking_logs, dependent: :destroy`（以降の `current_user.user_smoking_logs` 利用のため）
- [x] バリデーション（`smoked_on` presence、`smoking_count >= 0`）
      -->

## ゴール

<!-- 実装クリア: ISSUE-30
- [x] 同一user+日付で2件目が作れない
-->

---

# ISSUE-31 今日ログの取得/作成ユーティリティ

## なぜ必要か

- **+1記録・スケジュール反映・（当日を含む）カレンダーからの保存・過去日の手動入力**など、保存操作で当日ログを一貫して扱うため
- **ダッシュボードを開いただけ**で `user_smoking_logs` 行が自動生成されると、未記録なのに snapshot 付きレコードが立ち、**節約額などが水増し表示**される問題を防ぐため

## 必要なこと(簡易的に)

- ISSUE-30完了
- ISSUE-20完了（snapshotのコピー元）

## 仕様（確定・ログ行ができるタイミング）

- **当日分のログ行**は、次の **保存操作をしたときだけ** `create` する。**ダッシュボードの表示（GET）だけでは作らない**
  - **+1記録**（ISSUE-32）
  - **スケジュール反映**（ISSUE-76）
  - **カレンダー／本数フォームからの保存**（当日・過去日とも ISSUE-33 等）
  - **過去日の手動入力・補正**（ISSUE-33）
- **ダッシュボード表示・当日を読むだけの処理**
  - DBに当日行があればそれを表示・**当日の節約見込み**の算出入力に使う
  - **なければ** `smoking_count = 0` の **仮想状態**として扱う（`build` 相当・**`save` しない**）
  - **累計節約（昨日までの確定分）には当日を含めない**（`smoked_on < Time.zone.today`）。当日分は **見込み**として別枠表示（ISSUE-50/53/61）
- **ISSUE-42（日付詳細）と整合**: **詳細の GET のみ**では **当日・過去日とも** `user_smoking_logs` を **`create` しない**（上記と同一原則）

## やること(コードレベル)

- **変更点（ファイル）**: `app/models/user_smoking_log.rb` / `app/models/user.rb` / `app/services/*`（例: `SmokingLog::Today`）など
<!-- 実装クリア: ISSUE-31
- [x] `smoked_on = Time.zone.today` で **持久化済みレコードを find** するAPIと、**未保存の仮想（0本相当）**を返すAPI（または1メソッドで `:persisted?` で分岐）を用意する
- [x] **create 用**（上記保存操作からのみ呼ぶ）: 当日行が無いときに限り `create` し、`*_snapshot` に `user_setting` の値をコピー（**5項目すべて**）
- [x] 既存行の snapshot は上書きしない（当日行も過去日も、作成時点で固定）
- [x] **過去日ログを後から新規作成する場合**の snapshot ルールは **ISSUE-33** と同一（保存時点の現在設定・既存行の snapshot は更新しない）
      -->

## ゴール

<!-- 実装クリア: ISSUE-31
- [x] **表示のみ**で当日の `user_smoking_logs` 行が増えない（DBに勝手にレコードができない）
- [x] **+1・反映・保存**などの操作時に当日行が作られ、snapshot が期待どおり入る
-->

---

# ISSUE-32 今日の「+1で記録」機能（加算）

## なぜ必要か

- MVPのメイン操作（毎日やること）を最短導線で提供するため

## 必要なこと(簡易的に)

- ISSUE-31完了（今日ログの取得/作成ユーティリティ）

## 加算の原子性（確定・同時リクエスト）

- **read-modify-write**（読み取り → メモリ上で `smoking_count += 1` → `save`）だけでは、並行リクエスト時に後勝ちで **加算漏れ** が起きうる
- **+1 加算は常に atomic な更新**とする。次のいずれか（または合理的な組み合わせ）で満たすこと：
  - 当日ログ行を **`with_lock`** で行ロックしてから加算・保存する
  - **`increment!`** / **`increment_counter`** など、Rails が **単一 SQL** で列を増やす API を使う
  - **`UPDATE user_smoking_logs SET smoking_count = smoking_count + 1 WHERE id = ?`** のように、DB 上で **式による加算**を1文で行う
- **推奨**：当日ログを **`with_lock` でロック**してから加算する（ISSUE-31 の取得／新規作成と **同一トランザクション**にまとめやすい）

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_smoking_logs_controller.rb` / `app/views/dashboard/*`
<!-- 実装クリア: ISSUE-32
- [x] `POST /today_smoking_log/increment` のような専用ルート（名前は任意）
- [x] controller で **このリクエストが保存操作**であることを前提に、当日行が無ければ **ISSUE-31 の create 経路**で新規行（snapshot 埋め）する
- [x] **上記「加算の原子性」どおり**、+1 を **atomic update** で行う（**`with_lock` 推奨**。`increment!` や `smoking_count = smoking_count + 1` 系 SQL でも可）
- [x] 連打・**同一ユーザーからの同時リクエスト**でも加算が欠落しないことを確認する（必要ならモデル／結合テスト）
      -->

## ゴール

<!-- 実装クリア: ISSUE-32
- [x] 連打でカウントが増える、リロード後も保持される
- [x] **同時リクエストでも加算漏れが発生しない**
-->

---

# ISSUE-33 過去日の編集・未記録日の補正（本数の新規/更新）

## なぜ必要か

- 記録ミスを直せないとデータの信頼性が崩れ、節約額/継続日数/モチベーションが壊れるため
- Plan の「カレンダーから過去日の編集」「スケジュール反映後のズレはカレンダーで修正」には、**行が無い過去日に後から本数を入れる**必要がある（既存行の `edit/update` だけでは未記録日へ進めない）

## 必要なこと(簡易的に)

- ISSUE-30完了（UserSmokingLog・snapshot方針が定まっている）

## 仕様（確定・過去日を含む snapshot）

- **過去日**のログを後から作成する場合も、`*_snapshot` は **その保存リクエスト時点**の `current_user.user_setting` をコピーする
- **当時の設定の再現は行わない**（`UserSetting` の変更履歴は持たない前提と同義）
- **既存ログ**の `*_snapshot` は **変更しない**（`smoking_count` 等、本数まわりのみ更新する）

## 当日扱い・日付境界（確定）

- ISSUE-33 の本数フォームは、**過去日および当日**を対象にできる
- 当日の通常記録は ISSUE-32 の「+1で記録」を主導線とするが、記録ミスやスケジュール反映後のズレを補正するため、当日もフォームから `smoking_count` を直接保存できる
- **未来日（`smoked_on > Time.zone.today`）は保存不可**とする
- 日付判定は必ず `Time.zone.today` を基準にする
- 詳細表示などの GET だけでは、当日・過去日とも `user_smoking_logs` を作成しない
- 未記録日にフォームから保存した場合は新規作成として扱い、保存時点の `current_user.user_setting` から snapshot 5項目をコピーする
- 既存ログの更新では `smoking_count` のみ更新し、snapshot は変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_smoking_logs_controller.rb` / `app/views/user_smoking_logs/new.html.erb` / `app/views/user_smoking_logs/edit.html.erb`（new/edit は共通化してもよい）
<!-- 実装クリア: ISSUE-33
- [x] 日付指定で **upsert 導線**を用意（例: `GET/POST ...?smoked_on=YYYY-MM-DD` または member で日付、`find_or_initialize_by(user:, smoked_on:)` で新規/既存を統一）
- [x] `smoked_on > Time.zone.today` の未来日は保存せず、フォームにエラーを表示する
- [x] **未記録日**は新規作成、**既存ログ**は更新（同一フォームでも可）
- [x] **上記「仕様（確定）」どおり**に snapshot（5項目・ISSUE-30どおりのカラム名）を扱う
  - [x] **新規作成時**（過去日の新規作成を含む）: 保存時点の `current_user.user_setting` を `*_snapshot` にコピー
  - [x] **既存ログの更新**（`edit`/`update`）: `smoking_count` 等のみ更新し、`*_snapshot` は変更しない
- [x] `resources :user_smoking_logs, only: [:new, :create, :edit, :update]` 等、ルートは上記に合わせて定義（本人の範囲のみ）
- [x] 不正アクセス防止（他ユーザーの日付・ログは404等）
      -->

## ゴール

<!-- 実装クリア: ISSUE-33
- [x] **未記録の過去日**でも本数を登録でき、カレンダー/詳細が更新される
- [x] 既存の過去日ログも編集でき、集計に反映される
-->

---

# ISSUE-40 simple_calendar導入 + 月カレンダー表示

## なぜ必要か

- 記録が「継続」につながるために、振り返り（履歴）が必要
- MVP要件の「カレンダー閲覧」を満たすため

## 必要なこと(簡易的に)

- ISSUE-30完了（表示するログがある）

## やること(コードレベル)

- **変更点（ファイル）**: `Gemfile` / `config/routes.rb` / `app/controllers/calendar_controller.rb` / `app/views/calendar/index.html.erb`
<!-- 実装クリア: ISSUE-40
- [x] `simple_calendar` 導入
- [x] `@logs = current_user.user_smoking_logs.where(smoked_on: range)` 取得
- [x] 日セルに `smoking_count` を表示（未記録は空）
- [x] **日付クリック**の遷移先は **ISSUE-42 の日付ベース詳細ルート**のみとする（ログIDの `show` へは向けない）
-->

## ゴール

<!-- 実装クリア: ISSUE-40
- [x] 月移動しても正しい月のログが見える
-->

---

# ISSUE-41 達成/未達の色分け表示（緑/赤）

## なぜ必要か

- 「達成/未達」を視覚的に即判断できるようにして、モチベ維持に繋げるため

## 必要なこと(簡易的に)

- ISSUE-40完了
- target情報（snapshot）がログに入っている（ISSUE-30/31）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/calendar/index.html.erb` / helper（必要なら）
<!-- 実装クリア: ISSUE-41
- [x] 判定メソッド（model or helper）を用意
- [x] Tailwindで背景/バッジなどを色分け
-->

## ゴール

<!-- 実装クリア: ISSUE-41
- [x] 目標達成日/未達日が一目で分かる
-->

---

# ISSUE-42 日付詳細ページ（表示＋編集導線）

## なぜ必要か

- 1日の内訳（本数/目標/節約）確認と、編集導線を提供するため

## 必要なこと(簡易的に)

- ISSUE-40完了
- ISSUE-33（編集）へ導線をつなぐ前提

## 仕様（確定・日付ベース詳細ルート）

- **詳細はログIDに依存しない**。未記録日でもURLで開ける **日付キー**のルートとする。実装例（どちらか一方でよい）:
  - `GET /user_smoking_logs/by_date?date=YYYY-MM-DD`（`collection` 等）
  - または `GET /user_smoking_logs/:date`（`:date` は `YYYY-MM-DD` 制約。`resources` の `show :id` と被らないようルート定義順・制約を整理）
- **挙動**: 指定日にログ行がある → そのレコードを表示。ない → **未記録**として詳細を表示（本数0・「未記録」等）
- **未記録日（ログ行が無く snapshot も無い）**の **目標・節約**の表示は **「―」（ダッシュ）**に統一する。**現在の `UserSetting` は参照しない**（設定が変わっても未記録日の表示がブレないようにし、表示分岐を単純化する）
- **ログ行がある日**のみ、`*_snapshot` に基づき目標・節約を算出・表示する（ISSUE-50 の日次式）
- **ISSUE-31 と同一原則**: 本ページの **GET（表示）だけ**では **`user_smoking_logs` を `create` しない**
- **カレンダー**からの遷移は **必ずこの日付ルート**とし、**ログIDのURLは使わない**
- コントローラは `current_user.user_smoking_logs.find_by(smoked_on: 指定日)` でよい（nil 許容）。アクション名は `by_date` 等でもよく、テンプレートは共通化してよい

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_smoking_logs_controller.rb` / `app/views/user_smoking_logs/show.html.erb`（または `by_date` 用テンプレートを `show` と共通化）
<!-- 実装クリア: ISSUE-42
- [x] 上記「仕様（確定）」どおり **日付ベース**のルートを定義する（**カレンダー導線で `GET /user_smoking_logs/:id` 型を使わない**）
- [x] 指定日のログがあればその本数・snapshot ベースの目標・節約を表示。**無い場合**は未記録として本数0等を示し、**目標・節約は「―」**（**`UserSetting` で補完しない**）
- [x] **本数修正**へのリンクを置く（ISSUE-33 の **new（日付指定）/ edit** のどちらでも同じフォームに着地できるようにする）
-->

## ゴール

<!-- 実装クリア: ISSUE-42
- [x] **未記録日**でも日付URLから詳細が開ける
- [x] **未記録日**の目標・節約が **「―」で一貫**し、**`UserSetting` フォールバックが無い**
- [x] カレンダー→詳細→（未記録を含む）本数修正の導線が機能する
-->

---

# ISSUE-50 節約額（日次/累計）計算ロジック実装

## なぜ必要か

- 本アプリの価値である「減らせた分＝節約」を金額化して見せるため

## 必要なこと(簡易的に)

- ISSUE-30完了（ログ）
- snapshots（baseline/pack_price）が入っている（ISSUE-31）

## 仕様（確定・節約の「当日」扱い）

- **累計節約（確定）**は **昨日まで**のみ：`user_smoking_logs` のうち **`smoked_on < Time.zone.today`** の行だけを `saved_yen` 合算する（**当日分は累計に入れない**）
- **今日の節約**は **別枠・見込み**として算出・表示する（当日のログ行、または ISSUE-31 の仮想0から日次式で `saved_yen` を出す）。**ラベルで見込みであることを明示**する（例: 「今日の節約見込み」）
- **表示の分離（確定）**: **累計は昨日までの確定**、**当日は見込みのみ別枠**。同一ラベル・同一欄に **確定累計と当日見込みを混在させない**（ダッシュボード ISSUE-53・詳細 ISSUE-42 と整合）
- **表示例**（文言イメージ）: 累計節約 12,000円（昨日まで）／今日の節約見込み 300円
- **継続日数（ISSUE-52）**と同様、**当日は「確定した累計・連続の対象外」**とする考え方で整合する

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（例: `Money::SavingsCalculator`）/ `app/models/user_smoking_log.rb`
<!-- 実装クリア: ISSUE-50
- [x] 1日分: `saved_cigs = [0, baseline_snapshot - smoking_count].max`、鬼モードは ISSUE-61 どおり
- [x] `saved_yen = (saved_cigs * pack_price_snapshot / cigarettes_per_pack_snapshot).floor`
- [x] **累計（確定）**: `smoked_on < Time.zone.today` の行のみ集計
- [x] **今日の見込み**: `smoked_on == Time.zone.today` の行があればそれを、なければ仮想0相当で別算出（累計ロジックと分離）
-->

## ゴール

<!-- 実装クリア: ISSUE-50
- [x] 当日の途中状態でも **累計が過大表示**されない（累計に当日が混入しない）
- [x] 今日の金額が **見込み**として **別枠**で表示でき、**累計（昨日まで確定）**と混同されない
-->

---

# ISSUE-51 使用可能金額（残高）算出ロジック実装

## なぜ必要か

- 「貯まった（節約した）お金で買う」体験の前提として残高が必要

## 必要なこと(簡易的に)

- ISSUE-50完了（節約額が出せる）
- purchase未実装でも0扱いにする方針

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（例: `Money::BalanceQuery`）
<!-- 実装クリア: ISSUE-51
- [x] **残高の分子**は ISSUE-50 の **累計節約（確定・昨日まで）**のみを使う（**節約見込みは残高に含めない**）
- [x] `cumulative_spent_yen = current_user.user_purchase_histories.sum(:amount)`（関連実装後に）
- [x] 一旦purchaseが未実装でも0扱いで表示できるようにする
-->

## ゴール

<!-- 実装クリア: ISSUE-51
- [x] 節約額と組み合わせて残高が表示できる（見込みで使える金額が水増しされない）
-->

---

# ISSUE-52 継続日数（連続達成）算出ロジック実装

## なぜ必要か

- 習慣化の指標として「続いている」ことを可視化し、継続モチベにするため

## 必要なこと(簡易的に)

- ISSUE-30完了（ログ）
- 達成判定にtarget_daily_cigarette_count_snapshotが必要（ISSUE-30/31）

## 仕様（確定・連続達成の数え方）

- **当日**（`Time.zone.today`）は連続日数に**含めない**
- **昨日**から **1日ずつ過去へ**カレンダー日をたどる（**ログがある日だけを拾いにいくのではなく**、欠けた日も含めて毎日を順に見る）
- **各日**について、次の順で判定する（その日で終了したら、それより過去は見ない）
  - **`user_smoking_logs` にその日付の行が無い** → **終了**
  - **未達**（`smoking_count > target_daily_cigarette_count_snapshot`）→ **終了**
  - **達成**（`smoking_count <= target_daily_cigarette_count_snapshot`）→ **連続カウントを1増やし**、さらに**前日**へ

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（例: `Streak::AchievementCounter`）
<!-- 実装クリア: ISSUE-52
- [x] **上記「仕様（確定）」どおり**に連続日数を算出する（達成/未達の定義は ISSUE-41 と同じ）
- [x] 例: **昨日にログ行が無い**場合、連続は **0**
-->

## ゴール

<!-- 実装クリア: ISSUE-52
- [x] 例データで期待通りの連続数になる
-->

---

# ISSUE-53 ダッシュボード表示（今日/残り/節約/残高/継続）

## なぜ必要か

- ユーザーが毎日開いて「記録→確認」できる中心画面が必要なため

## メモ

- ルーティング・空の `index` ビューは **ISSUE-22**（Plan.md の画面分離：初期設定保存後＝`dashboard`）で先行。本 Issue は指標・+1 等の**中身**を実装する。

## 必要なこと(簡易的に)

- ISSUE-31/32（今日ログ）
- ISSUE-50/51/52（集計）
- **ISSUE-61完了**（Plan.mdどおり、鬼モードON時は目標超過日の節約加算0円を節約計算に含めてから、ダッシュボードで節約・残高を表示する。**ドキュメント上の並びより先に ISSUE-61 を完了してから本Issueに着手すること**）

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/dashboard_controller.rb` / `app/views/dashboard/index.html.erb`
<!-- 実装クリア: ISSUE-53
- [x] **当日**は ISSUE-31 に従い、DB のログ行 **または** `smoking_count = 0` の仮想状態を表示する（**`index` 表示だけではログ行を create しない**）
- [x] **節約表示**は ISSUE-50 どおり **二系統**に分ける:**累計節約（昨日までの確定）** と **今日の節約見込み**（ラベルで見込みと明示）
- [x] **残高**は ISSUE-51 どおり、**確定累計 − 使用累計**（今日の見込みは残高に含めない）
- [x] 継続日数（ISSUE-52・当日除外）とあわせて表示
-->
- [x] 「+1で記録」ボタンを配置（ISSUE-32と接続）

## ゴール

<!-- 実装クリア: ISSUE-53
- [x] ログイン後にダッシュボードが表示され、指標が更新される
- [x] 当日の途中でも **累計・残高が過大**にならない（見込みは別枠）
-->

---

# ISSUE-60 鬼モードON/OFF UI（設定画面）

## なぜ必要か

- MVP要件の鬼モードをユーザーが切り替えられるようにするため

## 必要なこと(簡易的に)

- ISSUE-23完了（設定編集画面がある）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_settings/edit.html.erb`
<!-- 実装クリア: ISSUE-60
- [x] checkboxを設置、説明文を付ける（目標超過日は節約が増えない）
-->

## ゴール

<!-- 実装クリア: ISSUE-60
- [x] ON/OFFが保存できる
-->

---

# ISSUE-61 鬼モードの節約計算反映（目標超過日は節約加算0）

## なぜ必要か

- 鬼モードの価値（完璧主義向けの厳格ルール）を節約計算へ反映しないと意味がないため

## 必要なこと(簡易的に)

- ISSUE-50完了（節約計算）
- ISSUE-23/60（is_oni_modeが設定できる）

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（節約計算）
<!-- 実装クリア: ISSUE-61
- [x] `if is_oni_mode_snapshot && smoking_count > target_daily_cigarette_count_snapshot then saved_cigs = 0 end`
- [x] 表示側（詳細/ダッシュボード）で反映後の値を使う
-->

## ゴール

<!-- 実装クリア: ISSUE-61
- [x] 同一ログでも鬼モードONで節約額が0になるケースが再現できる
-->

---

# ISSUE-62 View partial化（重複UIの整理）

## なぜ必要か

- 設定フォームやダッシュボード指標など、同じ見た目・同じ構造のERBが増えてきたため
- 後続のスケジュール、wishlist、購入画面を追加する前に、変更しやすいView構成に整えるため
- UI文言やclass変更時に複数ファイルを手作業で揃える負担を減らすため

## 必要なこと(簡易的に)

- ISSUE-53完了（ダッシュボード指標表示）
- ISSUE-60完了（設定編集画面の鬼モードUI）
- 既存テストが通っていること

## 方針

- 見た目やフォーム構造の重複だけをpartial化する
- controller、model、service の責務や挙動は変えない
- 既存の表示文言、リンク先、フォーム送信先、HTTP method、validation表示を変えない
- partial化によってテストの期待値を弱めない

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_settings/*` / `app/views/dashboard/*` / 必要に応じて `app/views/shared/*`
<!-- 実装クリア: ISSUE-62
- [x] `app/views/user_settings/_form.html.erb` を作り、`new.html.erb` と `edit.html.erb` の設定フォーム重複をまとめる
  - [x] 目標本数、基準本数、1箱価格、1箱本数、鬼モード、エラー表示、保存ボタンを共通化する
  - [x] `new` は `url: user_setting_path`、`edit` は既存どおり `model: @user_setting` で保存できるようにする
  - [x] edit固有の「ダッシュボードへ戻る」リンクはpartialに混ぜず、edit側に残す
- [x] `app/views/dashboard/_metric_card.html.erb` を作り、累計節約・今日の節約見込み・使用可能金額・継続日数のカード表示をまとめる
  - [x] 補足文があるカード、ないカードの両方を扱えるようにする
- [x] `app/views/dashboard/_today_stat.html.erb` を作り、今日の本数・目標・残りの表示ブロックをまとめる
- [x] 必要なら `app/views/shared/_form_errors.html.erb` を作り、`errors.full_messages` の表示を共通化する
-->

## 対象外

- Devise 画面のフォーム整理は対象外（後でまとめて調整する）
- `user_smoking_logs/_form.html.erb` は既にpartial化済みなので、今回の主対象にはしない
- デザインの大幅変更、文言変更、導線変更はしない

## ゴール

<!-- 実装クリア: ISSUE-62
- [x] 既存の画面表示とフォーム保存挙動を変えずに、Viewの重複が減っている
- [x] `docker compose run --rm web bin/rails test` が通る
- [x] `docker compose run --rm web bundle exec rubocop` が通る
- [x] UI表示に影響するため、必要に応じてPlaywrightでダッシュボードと設定編集画面を確認する
-->

---

# ISSUE-70 UserScheduleテーブル/モデル作成

## なぜ必要か

- 「固定時間の喫煙をまとめて反映」するためのデータ土台が必要

## 必要なこと(簡易的に)

- ISSUE-10完了（User）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_schedule.rb` / `app/models/user.rb`
<!-- 実装クリア: ISSUE-70
- [x] migration作成（`user:references`, `scheduled_smoking_time:time`, `label`, `is_active default:true`）
- [x] `User has_many :user_schedules, dependent: :destroy`
-->
<!-- 実装クリア: ISSUE-76
- [x] **`UserSchedule has_many :user_schedule_reflections, dependent: :destroy`**（**`UserScheduleReflection` モデル・テーブル追加後**／ISSUE-76 と同時でよい）
-->
<!-- 実装クリア: ISSUE-70
- [x] バリデーション（time presence 等）
-->

## ゴール

<!-- 実装クリア: ISSUE-70
- [x] consoleでCRUDできる
-->

---

# ISSUE-71 スケジュール一覧

## なぜ必要か

- 作成/編集/削除へ入る入口が必要なため（CRUDの起点）

## 必要なこと(簡易的に)

- ISSUE-70完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_schedules_controller.rb` / `app/views/user_schedules/index.html.erb`
<!-- 実装クリア: ISSUE-71
- [x] `resources :user_schedules` を追加（名前は任意）
- [x] `index` で `current_user.user_schedules` を表示
-->

## ゴール

<!-- 実装クリア: ISSUE-71
- [x] ログインユーザーのスケジュールだけが表示される
-->

---

# ISSUE-72 スケジュール作成

## なぜ必要か

- スケジュールが登録できないと、反映機能（時短）が成立しないため

## 必要なこと(簡易的に)

- ISSUE-71完了（一覧/導線）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_schedules/new.html.erb` / `user_schedules_controller.rb`
<!-- 実装クリア: ISSUE-72
- [x] `new/create` 実装（本人紐付け）
- [x] バリデーションエラー表示
-->

## ゴール

<!-- 実装クリア: ISSUE-72
- [x] 作成後に一覧に表示される
-->

---

# ISSUE-73 スケジュール編集

## なぜ必要か

- 時刻/ラベルは生活に合わせて変わるため、編集できる必要があるため

## 必要なこと(簡易的に)

- ISSUE-72完了（作成できる）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_schedules/edit.html.erb`
<!-- 実装クリア: ISSUE-73
- [x] `edit/update` 実装（本人のみ）
-->

## ゴール

<!-- 実装クリア: ISSUE-73
- [x] 更新が保存される
-->

---

# ISSUE-74 スケジュール削除

## なぜ必要か

- 使わなくなったスケジュールを整理できないと運用が辛くなるため

## 必要なこと(簡易的に)

- ISSUE-71完了

## やること(コードレベル)

- **変更点（ファイル）**: `user_schedules_controller.rb`
<!-- 実装クリア: ISSUE-74
- [x] `destroy` 実装（本人のみ）
- [x] 削除後リダイレクト
-->

## ゴール

<!-- 実装クリア: ISSUE-74
- [x] 一覧から消える
-->

---

# ISSUE-75 スケジュールON/OFF切替

## なぜ必要か

- 削除せずに「一時的に反映対象から外す」運用が必要なため

## 必要なこと(簡易的に)

- ISSUE-71完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `user_schedules_controller.rb` / `index.html.erb`
<!-- 実装クリア: ISSUE-75
- [x] member route（例: `PATCH /user_schedules/:id/toggle`）
- [x] `is_active = !is_active` で保存
-->

## ゴール

<!-- 実装クリア: ISSUE-75
- [x] OFFにすると「反映対象から外れる」準備ができる
-->

---

# ISSUE-76 スケジュールを今日ログへ反映（1スケジュール=1本）

## なぜ必要か

- 「記録の手間を減らす」というスケジュール機能の価値をMVPで体験可能にするため

## 必要なこと(簡易的に)

- ISSUE-31（今日ログ）
- ISSUE-75（active判定）

## 仕様（確定・スケジュール反映方式）

- MVPでは **方式Bのみ**を採用する。**方式A・方式Cは採用しない**
- **方式B**: **`user_schedule_reflections`** により **スケジュールID × 日付（`reflected_on`）**ごとに「その日そのスケジュールは反映済み」を管理する。ER（`@.codex/rules/ER.md`）どおり **`(user_schedule_id, reflected_on)` ユニーク**
- **方式A（採用しない）**: 反映済みを **件数差分だけ**で表す（同日のスケジュール入れ替えで漏れが出る）
- **方式C（採用しない）**: **`user_schedule_reflections` を使わない**二重加算防止（別テーブル・別キー、ログ行への直接紐づけのみ等、ERと一致しない設計）

## 当日ログ新規作成時の snapshot（確定・ISSUE-76）

- 反映処理で **当日の `user_smoking_logs` を新規 `create` する場合**、**ISSUE-30 / ISSUE-31 と同一**に **`current_user.user_setting` から 5 項目すべて**を `*_snapshot` にコピーする（**`target_daily_cigarette_count_snapshot` / `baseline_daily_cigarette_count_snapshot` / `pack_price_snapshot` / `cigarettes_per_pack_snapshot` / `is_oni_mode_snapshot`**。欠け・省略なし）

## トランザクション境界（確定・複数タブ・連打対策）

**`ActiveRecord::Base.transaction`（または同等）1回**で、次の **1〜5 を包む**（**コミットまでに完結**。取得 or 作成・`with_lock`・未反映取得・加算・reflection 作成を **別トランザクションに分割しない**）。途中失敗は **全体ロールバック**。**処理の流れは1サービスメソッド（またはコントローラ内の1ブロック）に集約**し、実装者が順序をばらけさせないこと。並行リクエスト時は **当日ログ行の `with_lock` により直列化**され、**UNIQUE 制約**と組み合わせて整合性を保つ。

1. **当日ログ**の取得、または無い場合は **ISSUE-31 の create 経路**による新規作成（**上記「当日ログ新規作成時の snapshot」どおり 5 項目コピー**）
2. 当日ログ行の **`with_lock`**（行ロック）
3. **未反映**スケジュールの取得（アクティブかつ **`(user_schedule_id, reflected_on=当日)` の reflection が無い**もの）
4. **`smoking_count` の加算**（対象スケジュール分）
5. **`user_schedule_reflections` の作成**（対象スケジュールごとに1行）

### 実装順の注意（二重加算を防ぐため）

上記4・5は **外側の同一トランザクション内**で行う。**コード上の実行順は各スケジュール単位で「`user_schedule_reflections` の INSERT が成功した場合にのみ `smoking_count` を +1」**とする（`insert_all` の `unique_by` と返り値、`create` + `RecordNotUnique` 捕捉、SAVEPOINT による加算後の UNIQUE 失敗時ロールバック等）。**先に加算だけ成功して UNIQUE で失敗**すると本数だけ増えるため避ける。**スケジュールごとにトランザクションを切らない**（内側の SAVEPOINT 等の有無は実装任せだが、**コミットは反映処理の最後に1回**）。

## 重複防止（確定）

- DB の **`(user_schedule_id, reflected_on)` ユニーク制約違反**（別タブ同時実行・連打など）は **二重反映**とみなし、**そのスケジュール分の `smoking_count` 加算は行わない**（既に reflection がある扱い）。他スケジュールの反映は続行してよい。
- **冪等（再実行）**: 同一ユーザーが **同じ日に反映を再実行**しても、既に `user_schedule_reflections` があるスケジュールは未反映一覧に含まれず、**本数は増えない**（再送・二重クリックで水増ししない）。

## モデル定義（確定）

- **`UserSchedule`**（`app/models/user_schedule.rb`、ISSUE-70 と整合）: **`has_many :user_schedule_reflections, dependent: :destroy`**
- **`UserScheduleReflection`**（`app/models/user_schedule_reflection.rb`）: **`belongs_to :user_schedule`**、**`validates :reflected_on, presence: true`**

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*`（`user_schedule_reflections` 等） / `config/routes.rb` / `app/controllers/schedule_reflections_controller.rb`（例）/ `app/views/dashboard/index.html.erb` / 関連モデル
<!-- 実装クリア: ISSUE-76
- [x] **1 つの `transaction` ブロック**で、当日ログ取得 or 作成（5 snapshot）→ `with_lock` → 未反映取得 → 加算 → reflection 作成までを行い、**途中でコミットしない**
- [x] **上記「トランザクション境界」「重複防止」「モデル定義」に沿い**、**アクティブ**かつ **当日分の reflection 未作成**のスケジュールのみ本数へ反映する（**1スケジュール=1本**・**二重加算なし**）
- [x] 当日ログを **無ければ ISSUE-31 の create 経路で新規作成（snapshot）し**、あれば取得し、**`with_lock`** してから未反映一覧・加算・reflection 作成を行う
- [x] 反映ボタンをダッシュボードに置く（確認ダイアログ等は任意）
-->

## ゴール

<!-- 実装クリア: ISSUE-76
- [x] 反映後に今日の本数が増える（OFFは除外）
- [x] **同一 `(user_schedule_id, reflected_on)` で本数が二重に増えない**（複数タブ・連打含む）
- [x] **スケジュール反映が完全に冪等**（再実行・連打で、既反映分の本数が水増ししない）
- [x] **並行実行**（複数タブ・同時 POST）でも **UNIQUE 違反時は加算せず**、ログ・reflection の整合が壊れない
- [x] **`UserSchedule` 削除時に `user_schedule_reflections` が孤立しない**（`dependent: :destroy`）
- [x] 実装者が **トランザクション境界と処理順**を TODO / コードのどちらかで迷わない
-->

---

# ISSUE-80 UserWishlistテーブル/モデル作成

## なぜ必要か

- 「節約できた金額の使い道（ご褒美）」を表現するための土台データが必要

## 画像（MVP・確定）

- **案Aを採用する**（推奨どおり）: **MVPでは画像機能なし**。`user_wishlists` に **`image` カラムは置かない**（アップロード・表示・URL保存はすべて**対象外**）
- **案B（外部画像URLのみ・非アップロード）**は **MVPでは採用しない**（拡張時に再検討）

## 必要なこと(簡易的に)

- ISSUE-10完了（User）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_wishlist.rb` / `app/models/user.rb`
<!-- 実装クリア: ISSUE-80
- [x] migration（`user:references`, `name`, `price`, `memo`, `is_purchased default:false`）— **`image` は含めない**（上記「画像（MVP・確定）」）
- [x] `User has_many :user_wishlists, dependent: :destroy`
- [x] バリデーション（name presence, price > 0）
-->

## ゴール

<!-- 実装クリア: ISSUE-80
- [x] consoleでCRUDできる
- [x] **画像仕様（案A）に沿い**、実装者が image の要否で迷わない
-->

---

# ISSUE-81 ウィッシュリスト一覧

## なぜ必要か

- 登録した「欲しいもの」を俯瞰し、次の行動（詳細/購入）へ進む入口が必要

## 必要なこと(簡易的に)

- ISSUE-80完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_wishlists_controller.rb` / `app/views/user_wishlists/index.html.erb`
<!-- 実装クリア: ISSUE-81
- [x] `resources :user_wishlists`
- [x] `index` 実装（本人のみ）
-->

## ゴール

<!-- 実装クリア: ISSUE-81
- [x] 一覧表示できる
-->

---

# ISSUE-82 ウィッシュリスト詳細

## なぜ必要か

- 購入判断やメモ確認のために、1件の情報をまとまって見れる必要があるため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_wishlists/show.html.erb`
<!-- 実装クリア: ISSUE-82
- [x] `show` 実装（本人のみ）
- [x] 購入ボタン（購入済みは非表示/disabled）
-->

## ゴール

<!-- 実装クリア: ISSUE-82
- [x] 詳細表示できる
-->

---

# ISSUE-83 ウィッシュリスト作成

## なぜ必要か

- 欲しいものが登録できないと「節約→ご褒美」の体験が成立しないため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `new.html.erb` / `create`
<!-- 実装クリア: ISSUE-83
- [x] `new/create` 実装
- [x] フォーム（name/price/memo）
-->

## ゴール

<!-- 実装クリア: ISSUE-83
- [x] 作成後に一覧/詳細へ
-->

---

# ISSUE-84 ウィッシュリスト編集

## なぜ必要か

- 価格やメモは後から変わるため、編集できる必要があるため

## 必要なこと(簡易的に)

- ISSUE-83完了

## やること(コードレベル)

- **変更点（ファイル）**: `edit.html.erb` / `update`
<!-- 実装クリア: ISSUE-84
- [x] `edit/update` 実装
-->

## ゴール

<!-- 実装クリア: ISSUE-84
- [x] 更新が保存される
-->

---

# ISSUE-85 ウィッシュリスト削除

## なぜ必要か

- 不要になった項目を整理できないと、運用が辛くなるため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `destroy`
<!-- 実装クリア: ISSUE-85
- [x] `destroy` 実装
-->

## ゴール

<!-- 実装クリア: ISSUE-85
- [x] 一覧から消える
-->

---

# ISSUE-90 UserPurchaseHistoryテーブル/モデル作成（wishlist 1件につき履歴1件）

## なぜ必要か

- 「購入＝使用した金額」を履歴として残し、残高計算（使用額）に使うため

## 必要なこと(簡易的に)

- ISSUE-80完了（wishlist）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_purchase_history.rb` / `app/models/user_wishlist.rb`
<!-- 実装クリア: ISSUE-90
- [x] migration（`user_wishlist:references{unique}`, `amount`, `purchased_at`）— **`user_id` は持たない**（利用者は wishlist 経由で特定する）
- [x] `UserPurchaseHistory belongs_to :user_wishlist`
- [x] `UserWishlist has_one :user_purchase_history, dependent: :destroy`
- [x] `User has_many :user_purchase_histories, through: :user_wishlists`（残高算出で `current_user.user_purchase_histories` を使うため）
- [x] DB制約（unique index on `user_wishlist_id`）
-->

## ゴール

<!-- 実装クリア: ISSUE-90
- [x] 同一wishlistに2件目が作れない
-->

---

# ISSUE-91 購入処理（残高チェック→履歴作成→購入済み更新、トランザクション）

## なぜ必要か

- MVPの「ご褒美で使う」体験の中心。整合性（残高・重複・更新順）を崩さず購入できる必要があるため

## スコープ（確定・不正アクセス防止）

- 購入対象の wishlist は **必ず** `current_user.user_wishlists.find(params[:id])` で取得する（**`UserWishlist.find(params[:id])` や、スコープなしの `find_by` 単体は禁止**）。他ユーザーの ID を指定されても **`ActiveRecord::RecordNotFound`** となり、操作できないこと

## 履歴の紐づけ（確定）

- **`user_purchase_histories` は `user_id` を持たず**、**`user_wishlist_id` のみ**で対応する wishlist に紐づく（ER `@.codex/rules/ER.md` と一致）
- 購入履歴は **`UserPurchaseHistory.create!` を単体で呼ばない**。**取得済みの `wishlist` 経由**で作成し、`user_wishlist_id` の未設定・取り違えを防ぐ
- **実装例**：`wishlist.create_user_purchase_history!(amount: wishlist.price, purchased_at: Time.current)`

## 必要なこと(簡易的に)

- ISSUE-51（残高算出）完了
- ISSUE-90（購入履歴）完了
- ISSUE-82（詳細）に購入ボタンを置く想定

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/purchases_controller.rb` / `app/services/*`（例: `Purchase::Create`）
<!-- 実装クリア: ISSUE-91
- [x] member route（例: `POST /user_wishlists/:id/purchase`）
- [x] **上記「スコープ（確定）」どおり**、wishlist を `current_user.user_wishlists.find(params[:id])` で取得してから購入処理に入る
- [x] **`ActiveRecord::Base.transaction` 内で、購入処理の先頭付近で `current_user.lock!`（または `User.lock.find` / `with_lock`）によりユーザ行をロック**し、**ロック取得後に**残高を再算出する（複数タブ・連打で同一の購入前残高を読み合い、合計が残高を超える履歴が作られるのを防ぐ）
- [x] ロック後の **`usable_yen >= wishlist.price`** を満たさない場合はロールバックしエラー
- [x] `wishlist.is_purchased`（必要なら `reload`）をチェックし、購入済みならエラー
- [x] 同一 transaction 内で
  - [x] **上記「履歴の紐づけ」どおり**、**取得済み `wishlist` 経由**で履歴を作成する（例：`wishlist.create_user_purchase_history!(amount: wishlist.price, purchased_at: Time.current)`）
  - [x] `wishlist.update!(is_purchased: true)`
-->

## ゴール

<!-- 実装クリア: ISSUE-91
- [x] 購入後に残高が減り、wishlistが購入済みになる
- [x] **購入履歴が必ず対応する wishlist に紐づく**（`user_wishlist_id` が常に正しい）
- [x] **並行リクエスト時も**残高を超える購入が成立しない
- [x] **他ユーザーの wishlist ID では購入できない**（スコープどおり）
-->

---

# ISSUE-92 残高不足時のエラー表示

## なぜ必要か

- 購入できない理由が分からないと離脱するため（UXの最低限）

## 必要なこと(簡易的に)

- ISSUE-91の購入処理がある

## やること(コードレベル)

- **変更点（ファイル）**: `purchases_controller.rb` / `user_wishlists/show.html.erb`
- [ ] flash等でメッセージ表示
- [ ] 購入ボタンのdisable条件（任意）

## ゴール

- [ ] 残高不足で購入できず、理由が表示される

---

# ISSUE-93 重複購入防止（購入済みの再購入不可）

## なぜ必要か

- 二重購入が起きると使用額/残高が壊れるため（整合性の最低限）

## 必要なこと(簡易的に)

- ISSUE-90（unique制約）
- ISSUE-91（購入フロー）

## やること(コードレベル)

- **変更点（ファイル）**: `Purchase::Create` / model validation（任意）/ view
- [ ] controller/service側で購入済みチェック
- [ ] DB制約（履歴 unique）でも担保

## ゴール

- [ ] 購入済みで購入URL叩いても失敗する

---

# ISSUE-94 購入履歴閲覧（wishlist単位）

## なぜ必要か

- 「買った」という達成感の可視化と、使用額の根拠を見せるため

## 必要なこと(簡易的に)

- ISSUE-90/91完了

## やること(コードレベル)

- **変更点（ファイル）**: `user_wishlists/show.html.erb`（または別ページ）
- [ ] wishlist詳細に `user_purchase_history` を表示

## ゴール

- [ ] 購入後に履歴が表示される

---

# ISSUE-99 仕上げ（バリデーション/テスト）

## なぜ必要か

- MVPとして最低限の品質（入力ミス時の分かりやすさ/壊れにくさ）と、公開可能状態を作るため

## 必要なこと(簡易的に)

- 主要機能が一通り実装済み

## やること(コードレベル)

- **変更点（ファイル）**: `spec/*` or `test/*` / `README.md` / Render設定
<!-- 実装クリア: ISSUE-99
- [x] 主要フォームのエラー表示統一（設定、ログ編集、wishlist）
- [x] Playwright 確認時のブラウザ warning 解消: `app/views/layouts/application.html.erb` に `<meta name="mobile-web-app-capable" content="yes">` を追加し、既存の `<meta name="apple-mobile-web-app-capable" content="yes"> is deprecated` warning を消す
- [x] 最低限テスト
  - [x] model: UserSetting validation、SavingsCalculator（鬼モード含む）
  - [x] system: 登録→設定→+1記録→wishlist購入 のハッピーパス
-->

## ゴール

<!-- 実装クリア: ISSUE-99
- [x] ローカルでハッピーパスが通る
-->

# ISSUE-100 UIの修正

## なぜ必要か

- MVP の機能実装は一通り完了したが、画面ごとの余白・見出し・ボタン・フォーム・一覧表示にばらつきがあり、ユーザーが次に何をすればよいか分かりにくい箇所が残っているため。
- 公開前の仕上げとして、ビジネスロジックを変えずに UI の読みやすさ・操作しやすさを整えるため。

## 必要なこと(簡易的に)

- ISSUE-99 完了
- 現在の Rails / Tailwind 構成を維持する
- ユーザーが Google Stitch で作成したコードを、ルート直下の `UI.md` に貼り付け済みであること
- 画面文言や導線を変更する場合は、既存の機能意図を崩さないこと

## やること(コードレベル)

- **変更点（ファイル）**: `UI.md` / `app/views/**/*.html.erb` / 必要に応じて partial
<!-- 実装クリア: ISSUE-100
- [x] `UI.md` に貼られた Google Stitch のコードを読み、Rails ERB / Tailwind に変換する方針を整理する
  - [x] Stitch の静的HTMLをそのまま貼り付けず、既存の Rails view / partial / helper の構造に合わせて移植する
  - [x] ダミーテキスト、ダミー数値、ダミーリンクは、既存のインスタンス変数・path helper・i18n相当の文言に置き換える
  - [x] Stitch 側にある不要な script、外部CDN、未使用画像、未使用CSSは追加しない
  - [x] Tailwind の既存クラスで実装できる範囲にする
- [x] `UI.md` のデザイン意図に沿って、主要ページの UI を調整する
  - [x] ダッシュボード
  - [x] 初期設定 / 設定編集
  - [x] 喫煙ログ作成 / 編集
  - [x] カレンダー / 日別詳細
  - [x] スケジュール一覧 / 作成 / 編集
  - [x] ウィッシュリスト一覧 / 作成 / 編集 / 詳細
  - [x] 購入履歴が表示される箇所
- [x] 画面共通で使える要素は partial 化を検討する
  - [x] ただし、共通化のためだけの大きなリファクタはしない
  - [x] 既存 partial がある場合は優先して使う
- [x] フォーム画面は入力欄、ラベル、説明、エラー表示、送信ボタンの並びを統一する
- [x] 一覧画面は空状態、通常状態、購入済み/有効無効などの状態が見分けられるようにする
- [x] ボタンとリンクは、主操作・副操作・危険操作が見分けられる見た目にする
- [x] スマホ幅で横スクロールや文字のはみ出しがないことを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-100
- [x] `UI.md` のGoogle Stitchコードをアプリに丸ごとコピーしない
- [x] DB schema を変更しない
- [x] 金額計算、残高計算、継続日数、snapshot、購入処理のロジックを変更しない
- [x] ルーティング、controller の主要な分岐、model validation を UI 目的で変更しない
- [x] 既存テストの期待値を、見た目変更と無関係に弱めない
- [x] `.codex/` や `AGENTS.md` をコミット対象にしない
-->

## ゴール

<!-- 実装クリア: ISSUE-100
- [x] 主要ページの見た目と操作感が `UI.md` の方針に沿っている
- [x] 既存の主要導線が壊れていない
- [x] Docker 経由のテストが通る
- [x] Playwright で主要導線を確認し、console error / warning がない
- [x] PC幅とスマホ幅の両方で大きな崩れがない
-->

---

# ISSUE-101 利用規約の作成

## なぜ必要か

- 公開アプリとして、ユーザーが利用前に基本的な利用条件を確認できる導線が必要なため
- Home画面の説明だけでは、免責・禁止事項・サービス内容の変更などの扱いが分からないため

## 必要なこと(簡易的に)

- ISSUE-100 完了
- Home画面に footer 領域を追加し、次の3つの導線を横並びまたは縦並びで表示する
  - 利用規約
  - プライバシーポリシー
  - お問い合わせ
- ISSUE-101 では **利用規約のPOPUPのみ実装**する
- プライバシーポリシーとお問い合わせは footer に文言だけ置いてよいが、実装は ISSUE-102 / ISSUE-103 で行う

## 仕様（確定）

- 利用規約は **画面遷移しないPOPUP** として表示する
- URL遷移用の `/terms` のような個別ページは作らない
- POPUPは Home画面内で開閉できること
- POPUPを閉じる手段を用意する
  - 閉じるボタン
  - 背景クリックまたは `Esc` キー対応は任意
- 利用規約の文面は MVP 用の簡易文面でよい
- 文面には最低限、次の内容を含める
  - ChillSmoke は減煙を支援する記録アプリであり、医療行為や禁煙治療を提供するものではないこと
  - 記録内容や節約額はユーザー入力に基づく目安であること
  - 不正利用、他者への迷惑行為、サービス運営を妨げる行為を禁止すること
  - サービス内容を変更・停止する場合があること
  - 利用規約を変更する場合があること

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/home/index.html.erb` / 必要に応じて `app/views/shared/_home_footer.html.erb` / 必要に応じて `app/javascript/*` または Stimulus controller
<!-- 実装クリア: ISSUE-101
- [x] Home画面の下部に footer を追加する
- [x] footer に「利用規約」「プライバシーポリシー」「お問い合わせ」の3リンクを表示する
- [x] 「利用規約」を押すと同一画面内でPOPUPが開く
- [x] POPUP内に利用規約の見出しと本文を表示する
- [x] POPUP内に閉じるボタンを置く
- [x] POPUP表示中も背景のUIと重なって読みにくくならないよう、overlay / 背景暗転 / z-index を調整する
- [x] PC幅・スマホ幅で本文が読め、画面外にはみ出さないようにする
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-101
- [x] 認証、ダッシュボード、記録、金額計算、購入処理のロジックを変更しない
- [x] DB schema を変更しない
- [x] 利用規約用の単独ページやルーティングを追加しない
- [x] ISSUE-102 のプライバシーポリシー本文POPUP、ISSUE-103 の問い合わせ送信処理をこのIssueで実装しない
-->

## ゴール

<!-- 実装クリア: ISSUE-101
- [x] Home画面の footer に「利用規約」が表示される
- [x] 「利用規約」を押すと画面遷移せずPOPUPが開く
- [x] POPUPの本文がPC幅・スマホ幅で読める
- [x] 閉じるボタンでPOPUPを閉じられる
- [x] Docker 経由のテストまたは最低限のRails読み込み確認が通る
- [x] Playwright/MCPで Home画面のPOPUP開閉を確認し、console error がない
-->

---

# ISSUE-102 プライバシーポリシーの作成

## なぜ必要か

- ユーザー登録、喫煙記録、wishlist、購入履歴など、個人に紐づく情報を扱うため
- 公開前に、どの情報をどの目的で扱うかをユーザーが確認できる導線が必要なため

## 必要なこと(簡易的に)

- ISSUE-101 完了
- Home画面 footer に「プライバシーポリシー」の導線があること
- ISSUE-102 では **プライバシーポリシーのPOPUPのみ実装**する
- 画面遷移はさせない

## 仕様（確定）

- プライバシーポリシーは **画面遷移しないPOPUP** として表示する
- URL遷移用の `/privacy` のような個別ページは作らない
- POPUPは Home画面内で開閉できること
- 文面には最低限、次の内容を含める
  - 取得する情報: 名前、メールアドレス、喫煙記録、設定値、wishlist、購入履歴、お問い合わせ内容
  - 利用目的: アカウント管理、記録表示、節約額・残高・継続日数の計算、お問い合わせ対応、サービス改善
  - 第三者提供は法令等に基づく場合を除き行わないこと
  - ユーザー本人からの問い合わせに応じて、確認・修正・削除相談に対応すること
  - Cookie / セッションをログイン状態の維持などに利用する場合があること
  - プライバシーポリシーを変更する場合があること

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/home/index.html.erb` / ISSUE-101 で footer partial を作った場合はその partial / 必要に応じて `app/javascript/*` または Stimulus controller
<!-- 実装クリア: ISSUE-102
- [x] footer の「プライバシーポリシー」を押すと同一画面内でPOPUPが開く
- [x] POPUP内にプライバシーポリシーの見出しと本文を表示する
- [x] POPUP内に閉じるボタンを置く
- [x] ISSUE-101 の利用規約POPUPと見た目・操作感を揃える
- [x] 2つのPOPUPが同時に開きっぱなしにならないようにする
- [x] PC幅・スマホ幅で本文が読め、画面外にはみ出さないようにする
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-102
- [x] 認証、ダッシュボード、記録、金額計算、購入処理のロジックを変更しない
- [x] DB schema を変更しない
- [x] プライバシーポリシー用の単独ページやルーティングを追加しない
- [x] ISSUE-103 の問い合わせ送信処理をこのIssueで実装しない
-->

## ゴール

<!-- 実装クリア: ISSUE-102
- [x] Home画面の footer に「プライバシーポリシー」が表示される
- [x] 「プライバシーポリシー」を押すと画面遷移せずPOPUPが開く
- [x] 利用規約POPUPと操作感が揃っている
- [x] 閉じるボタンでPOPUPを閉じられる
- [x] Docker 経由のテストまたは最低限のRails読み込み確認が通る
- [x] Playwright/MCPで Home画面のPOPUP開閉を確認し、console error がない
-->

---

# ISSUE-103 お問い合わせフォームの作成

## なぜ必要か

- ユーザーが不具合、要望、アカウント・データに関する相談を送れる窓口が必要なため
- 公開後のフィードバックを受け取れる状態にするため

## 必要なこと(簡易的に)

- ISSUE-101 完了
- Home画面 footer に「お問い合わせ」の導線があること
- 名前、メールアドレス、内容を入力できるフォームを作る
- 送信先は `CONTACT_MAIL_TO` 環境変数で指定する

## 仕様（確定）

- お問い合わせフォームは Home画面 footer の「お問い合わせ」から開く
- 画面遷移方式は次のどちらかに統一する
  - 推奨: 利用規約・プライバシーポリシーと同じく Home画面上のPOPUP
  - 代替: 実装上POPUPが複雑になりすぎる場合のみ、`/contact` の単独フォーム画面
- ただし、footer の「お問い合わせ」からユーザーが迷わず入力できること
- 入力項目は次の3つ
  - 名前: 必須
  - メールアドレス: 必須、メール形式
  - 内容: 必須
- 送信ボタンで `CONTACT_MAIL_TO` 宛にメール送信する
- 送信完了時は、ユーザーに完了メッセージを表示する
- 入力エラー時は、どの項目が不足しているか分かるように表示する
- DB保存は不要。問い合わせ内容をDBに保存しない
- secret、SMTPユーザー名、SMTPパスワード、アプリパスワードはコミットしない
- 本番で実送信する場合は環境変数でSMTP設定を行う
- 開発・テストでは実メール送信ではなく、ActionMailer の test delivery 等で確認する

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/contacts_controller.rb` / `app/mailers/contact_mailer.rb` / `app/views/contact_mailer/*` / `app/views/home/index.html.erb` または footer partial / `test/*`
<!-- 実装クリア: ISSUE-103
- [x] 問い合わせ用のフォームオブジェクトを作る
  - [x] DBテーブルを作らず `ActiveModel::Model` 等で `name`, `email`, `message` を扱う
  - [x] `name`, `email`, `message` の presence validation を設定する
  - [x] `email` は最低限のメール形式 validation を設定する
- [x] 問い合わせ送信用の controller action を作る
  - [x] 正常時は `ContactMailer` でメールを送る
  - [x] 正常時は完了メッセージを表示する
  - [x] 異常時は入力内容を保持してエラーを表示する
- [x] `ContactMailer` を作る
  - [x] 宛先は `CONTACT_MAIL_TO` 環境変数から取得する
  - [x] 件名に `ChillSmoke お問い合わせ` など、サービス名が分かる文言を含める
  - [x] 本文に名前、メールアドレス、内容を含める
  - [x] 返信先として入力メールアドレスを設定できる場合は `reply_to` に入れる
- [x] Home画面 footer の「お問い合わせ」からフォームを開けるようにする
- [x] 送信成功・送信失敗・validation error の表示を確認する
- [x] test 環境では `ActionMailer::Base.deliveries` 等で送信先・件名・本文を確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-103
- [x] 問い合わせ内容をDB保存しない
- [x] SMTP認証情報や個人のアプリパスワードをリポジトリに書かない
- [x] 認証、ダッシュボード、記録、金額計算、購入処理のロジックを変更しない
- [x] 既存のDeviseメール設定を問い合わせのために壊さない
-->

## ゴール

<!-- 実装クリア: ISSUE-103
- [x] Home画面 footer の「お問い合わせ」からフォームを開ける
- [x] 名前、メールアドレス、内容を入力して送信できる
- [x] validation error が分かりやすく表示される
- [x] test で環境変数の宛先へメールが作成されることを確認できる
- [x] Docker 経由のテストが通る
- [x] Playwright/MCPで問い合わせフォームの表示・入力・送信完了またはvalidation errorを確認し、console error がない
-->

---

# ISSUE-104 パスワード入力内容の一時表示ボタン

## なぜ必要か

- ログイン、新規登録、パスワード変更時に入力ミスへ気づきやすくするため
- ただし、パスワードは機密情報なので常時表示ではなく、ユーザーが明示操作した間だけ確認できるようにするため

## 必要なこと(簡易的に)

- Devise のログイン・新規登録・パスワード変更画面が存在すること
- Stimulus controller など、既存のフロント実装方針に合わせて小さく実装すること
- アイコンまたは短いボタンで「押している間だけ表示」「離したら伏せ字に戻る」挙動にすること

## 仕様（確定）

- 対象はパスワード入力欄を持つ Devise 画面
  - ログイン: `app/views/devise/sessions/new.html.erb`
  - 新規登録: `app/views/devise/registrations/new.html.erb`
  - アカウント編集でパスワード欄がある場合: `app/views/devise/registrations/edit.html.erb`
  - パスワード再設定後の変更画面: `app/views/devise/passwords/edit.html.erb`
- 通常時は `type="password"` のまま伏せ字表示にする
- 表示ボタンを押している間だけ対象 input を `type="text"` に切り替える
- マウス操作だけでなくスマホのタッチ操作でも確認できるようにする
- ボタンからフォーカスが外れた場合、pointer cancel、touch cancel、Escape 相当の操作でも伏せ字に戻るようにする
- パスワード確認欄がある画面では、パスワード欄と確認欄を別々に表示切替できるようにする
- 見た目は既存の暗色 UI に合わせ、入力欄の右端に小さく配置する
- 表示切替によって入力値を消さない
- 表示切替によってフォーム送信、Devise の validation、autocomplete を壊さない

## やること(コードレベル)

- **変更点（ファイル）**: `app/javascript/controllers/*` / `app/views/devise/sessions/new.html.erb` / `app/views/devise/registrations/new.html.erb` / `app/views/devise/registrations/edit.html.erb` / `app/views/devise/passwords/edit.html.erb` / 必要に応じて `test/*`
<!-- 実装クリア: ISSUE-104
- [x] パスワード表示切替用の Stimulus controller を作る
  - [x] 対象 input を target として扱う
  - [x] `pointerdown` / `pointerup` / `pointerleave` / `pointercancel` で表示・非表示を切り替える
  - [x] `touchstart` / `touchend` / `touchcancel` が必要な場合はスマホ確認に合わせて追加する
  - [x] `blur` 時は必ず `type="password"` に戻す
- [x] Devise の各パスワード入力欄に controller と target を設定する
  - [x] ログイン画面の `password`
  - [x] 新規登録画面の `password`
  - [x] 新規登録画面の `password_confirmation`
  - [x] アカウント編集画面の `password` / `password_confirmation` / `current_password`（存在する場合）
  - [x] パスワード再設定後の変更画面の `password` / `password_confirmation` は ISSUE-103 で再設定機能を削除済みのため対象外
- [x] 表示ボタンを入力欄右端に置く
  - [x] `button type="button"` にする
  - [x] `aria-label` を付ける（例: `パスワードを押している間だけ表示`）
  - [x] 既存 UI と同じ色・角丸・余白にする
- [x] 表示切替後もフォーム送信できることを確認する
- [x] PC幅・スマホ幅で入力欄、ボタン、エラー表示が重ならないことを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-104
- [x] Devise の認証ロジック、登録ロジック、パスワード validation を変更しない
- [x] パスワードをログ、DB、画面上の別要素、hidden field に残さない
- [x] 常時表示やトグル固定表示にはしない（このIssueでは「押している間だけ表示」に統一）
- [x] ブラウザの password manager / autocomplete を壊さない
- [x] 認証、ダッシュボード、記録、金額計算、購入処理のロジックを変更しない
-->

## ゴール

<!-- 実装クリア: ISSUE-104
- [x] 対象画面のパスワード欄は通常時に伏せ字で表示される
- [x] 表示ボタンを押している間だけ入力内容が見える
- [x] ボタンを離す、キャンセルされる、フォーカスが外れると伏せ字に戻る
- [x] 入力値が消えず、フォーム送信も壊れない
- [x] PC幅・スマホ幅で UI が崩れない
- [x] Docker 経由のテストが通る
- [x] Playwright/MCPでログイン画面・新規登録画面・パスワード変更画面の表示切替を確認し、console error がない
-->

---

# ISSUE-105 ダッシュボードから0本ログを記録できるようにする

## なぜ必要か

- 現状のダッシュボードでは、当日ログを作る入口が「+1で記録」または編集画面からの保存に寄っているため
- 実際には、タバコを持っていない日、吸わなかった日、減煙が進んで0本の日もあり得るため
- 0本の日を記録するために、一度 `+1` で1本ログを作ってから編集で0本へ戻すのは手間が大きいため
- ChillSmoke は禁煙強制アプリではなく減煙支援アプリなので、「今日は吸わなかった」を自然に記録できる導線が必要なため

## 必要なこと(簡易的に)

- ISSUE-31 / ISSUE-32 完了
- ダッシュボードに当日の喫煙ログ表示と `+1で記録` 導線があること
- 当日ログの新規作成時に、ISSUE-30 / ISSUE-31 と同じ snapshot 5項目を保存できること
- 表示だけでログを作らない既存方針を維持すること

## 仕様（確定）

- ダッシュボードに `0本として記録` の操作を追加する
- `0本として記録` は、当日ログが未作成の場合に、当日の `user_smoking_logs` を `smoking_count: 0` で作成する
- 新規作成時は、保存時点の `current_user.user_setting` から snapshot 5項目をコピーする
  - `target_daily_cigarette_count_snapshot`
  - `baseline_daily_cigarette_count_snapshot`
  - `pack_price_snapshot`
  - `cigarettes_per_pack_snapshot`
  - `is_oni_mode_snapshot`
- 当日ログがすでに存在する場合は、新規作成せず既存ログを維持する
- 既存ログがある状態で `0本として記録` を押しても、既存の `smoking_count` や snapshot を勝手に上書きしない
- `0本として記録` は `+1で記録` より目立たない見た目にする
- 操作後はダッシュボードへ戻し、0本として記録したことが分かるメッセージを表示する
- ダッシュボードを開いただけでは、これまで通りDBに当日ログを作成しない
- 未来日ログ、過去日ログ、カレンダー詳細の仕様はこのIssueでは変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_smoking_logs_controller.rb` / `app/services/smoking_log/today.rb` または `app/models/user_smoking_log.rb` / `app/views/dashboard/index.html.erb` / 必要に応じて `test/*`
<!-- 実装クリア: ISSUE-105
- [ ] 当日ログを0本で永続化する処理を用意する
  - [ ] 当日ログが無ければ `smoking_count: 0` で作成する
  - [ ] 作成時に `current_user.user_setting` から snapshot 5項目をコピーする
  - [ ] 当日ログが既にあれば、既存ログを返すだけにする
  - [ ] 既存ログの `smoking_count` と snapshot を上書きしない
- [ ] 0本記録用のPOSTルートを追加する
  - [ ] `GET` ではなく保存操作として `POST` にする
  - [ ] 既存の `increment_today` と命名・配置の雰囲気を揃える
- [ ] controller action を追加する
  - [ ] ログインユーザーの当日ログだけを対象にする
  - [ ] 処理後は `dashboard_path` へ redirect する
  - [ ] 成功時の flash メッセージを表示する
- [ ] ダッシュボードに `0本として記録` ボタンを追加する
  - [ ] `+1で記録` より目立たない色・サイズ・配置にする
  - [ ] 当日ログが未作成の場合に自然に押せる位置へ置く
  - [ ] 既存の編集導線を壊さない
- [ ] model/service/controller test を追加または更新する
  - [ ] 当日ログ未作成時に0本ログが作成される
  - [ ] snapshot 5項目が保存時点の `user_setting` からコピーされる
  - [ ] 既存ログがある場合は本数も snapshot も上書きされない
  - [ ] ダッシュボードGETだけではログが作成されない
  - [ ] 未ログイン時はDeviseの認証に従って弾かれる
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-105
- [ ] ダッシュボードGET表示だけで当日ログを作成しない
- [ ] `+1で記録` の加算処理、atomic update、ロック方針を壊さない
- [ ] 既存ログの snapshot を更新しない
- [ ] 過去日編集、カレンダー詳細、スケジュール反映の仕様を変更しない
- [ ] 金額計算、残高計算、継続日数、購入処理のロジックを変更しない
-->

## ゴール

<!-- 実装クリア: ISSUE-105
- [ ] ダッシュボードから、当日を0本として直接記録できる
- [ ] 0本記録後、当日のログが `smoking_count: 0` でDBに保存される
- [ ] 0本ログにも snapshot 5項目が正しく保存される
- [ ] 0本記録のために、一度 `+1` してから編集で0本に戻す必要がない
- [ ] 既存ログがある日に誤って0本操作をしても、既存の本数や snapshot が上書きされない
- [ ] Docker 経由のテストが通る
- [ ] Playwright/MCPでダッシュボードの `+1で記録` / `0本として記録` / 編集導線を確認し、console error がない
-->

---

# ISSUE-106 メール送信が必要な問い合わせ機能を一時的にX導線へ変更する

## なぜ必要か

- SMTP未設定の本番環境で問い合わせフォームを送信すると、`localhost:25` へ接続しようとして `ECONNREFUSED` になるため
- 就活用ポートフォリオのMVPとして、外部メール送信の設定不備で500画面を見せるより、確実に連絡できる導線を優先するため
- パスワード再設定メールもSMTPが必要なため、メール基盤を用意するまでは再設定導線を出さない方が安全なため

## 必要なこと(簡易的に)

- ISSUE-103 の問い合わせフォームが実装済みであること
- 本番でSMTP未設定の場合に500が出る問題を把握していること
- 連絡先として X アカウント `@K2kitano02` を使うこと

## 仕様（確定）

- footer の「お問い合わせ」は、同一画面のPOPUPとして残す
- POPUP内には問い合わせフォームを置かず、Xへの連絡導線を表示する
- Xリンクは `https://x.com/K2kitano02` にする
- `target="_blank"` と `rel="noopener"` を付ける
- 問い合わせ内容はDB保存しない
- メール送信用 controller / mailer / form object / view は削除する
- Devise のパスワード再設定ルートは無効化し、SMTP不要の状態にする
- ログイン、登録、ダッシュボード、記録、金額計算、購入処理は変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/views/home/index.html.erb` / `app/mailers/contact_mailer.rb` / `app/controllers/contacts_controller.rb` / `app/models/contact_form.rb` / `app/views/contact_mailer/*` / `test/*`
<!-- 実装クリア: ISSUE-106
- [x] Home画面の問い合わせPOPUPをX導線に変更する
- [x] Xリンクを `https://x.com/K2kitano02` にする
- [x] 問い合わせフォーム、送信ボタン、メール送信処理を削除する
- [x] 問い合わせ用 route / controller / mailer / form object / mailer view を削除する
- [x] Devise のパスワード再設定ルートを無効化する
- [x] 既存テストをX導線前提に更新する
- [x] Docker 経由のテストが通ることを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-106
- [x] X連絡先以外の個人メールアドレスをコードへ書かない
- [x] SMTP認証情報、APIキー、アプリパスワードをリポジトリに書かない
- [x] 認証、記録、金額計算、購入処理を変更しない
-->

## ゴール

<!-- 実装クリア: ISSUE-106
- [x] 本番で問い合わせPOPUPを開いてもメール送信エラーが起きない
- [x] ユーザーがXから連絡できる
- [x] パスワード再設定メール送信が必要な導線を出さない
-->

---

# ISSUE-107 喫煙スケジュール一覧のスマホ表示と並び順を修正する

## なぜ必要か

- 実機スマホで喫煙スケジュール一覧を確認した際、ラベル末尾だけが改行されたり、状態バッジの文字が潰れたりしていたため
- スケジュール時刻の並び順がユーザーの直感とずれて見え、一覧として確認しづらかったため

## 必要なこと(簡易的に)

- ISSUE-70〜75 のスケジュール機能が実装済みであること
- スマホ幅で一覧表示を確認すること

## 仕様（確定）

- 喫煙スケジュール一覧は、時刻の昇順で表示する
- 同じ時刻のデータがある場合は、作成順またはID順で安定した並びにする
- スマホ幅でもラベルと状態バッジが潰れないようにする
- 状態表示は「有効」「無効」が読めるサイズと余白を確保する
- ON/OFF切替、編集、削除の機能は変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `app/controllers/user_schedules_controller.rb` / `app/views/user_schedules/index.html.erb` / 必要に応じて `test/*`
<!-- 実装クリア: ISSUE-107
- [x] 一覧取得時の並び順を時刻昇順にする
- [x] 同時刻でも表示順がぶれないようにする
- [x] スマホ幅でラベルが不自然に1文字だけ改行されないようにする
- [x] 状態バッジが潰れないように余白と幅を調整する
- [x] 既存のトグル、編集、削除導線を壊さない
- [x] Docker 経由のテストが通ることを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-107
- [x] スケジュール反映ロジックを変更しない
- [x] スケジュールの作成・編集・削除・ON/OFF切替の仕様を変更しない
- [x] DB schema を変更しない
-->

## ゴール

<!-- 実装クリア: ISSUE-107
- [x] スマホ幅でもスケジュール一覧が読みやすい
- [x] スケジュールが時刻順に自然に並ぶ
- [x] 既存機能の操作が変わらない
-->

---

# ISSUE-108 エラーメッセージを日本語化し、不正入力で500画面を出さない

## なぜ必要か

- アプリ全体のUIが日本語なのに、validation error が英語表記だとユーザーに伝わりにくいため
- ダッシュボードの日付指定記録などで極端に大きい本数を入力した場合、例外で500画面を表示するのではなく、通常の入力エラーとして扱うべきため

## 必要なこと(簡易的に)

- 既存validationの対象項目を確認する
- Rails/ActiveModel/Devise のエラー文言を日本語で表示できるようにする
- `10000000000` のような現実的でない本数入力をアプリ側で弾く

## 仕様（確定）

- validation error は日本語で表示する
- 喫煙本数は現実的な上限を設け、上限超過時はvalidation errorにする
- 不正入力で `We're sorry, but something went wrong.` の500画面を出さない
- 正常系の登録、編集、+1記録、0本記録は壊さない
- エラー表示は既存UIの見た目に合わせる

## やること(コードレベル)

- **変更点（ファイル）**: `config/locales/*` / `app/models/*` / `app/controllers/user_smoking_logs_controller.rb` / `test/*`
<!-- 実装クリア: ISSUE-108
- [x] validation error の日本語localeを整備する
- [x] Devise / ActiveRecord / ActiveModel の主要エラー文言を日本語化する
- [x] 喫煙本数の上限validationを追加する
- [x] 極端な数値入力をcontroller/modelで通常の入力エラーにする
- [x] 不正入力時もフォームへ戻ってエラーを表示する
- [x] Docker 経由のテストが通ることを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-108
- [x] 金額計算、snapshot、継続日数、購入処理を変更しない
- [x] 正常な喫煙本数の登録・更新を壊さない
- [x] 500画面を隠すためだけに例外を握りつぶさない
-->

## ゴール

<!-- 実装クリア: ISSUE-108
- [x] エラー文言が日本語で表示される
- [x] 極端な本数入力でも500にならず、入力エラーとして戻る
- [x] Docker 経由のテストが通る
-->

---

# ISSUE-109 就活向けに背景画像とUI表現を調整する

## なぜ必要か

- 以前の背景画像が就活用ポートフォリオとして誤解を招く可能性があったため
- ChillSmoke の「落ち着いた減煙支援アプリ」という印象を残しつつ、面接やREADMEで見せやすい画面にするため

## 必要なこと(簡易的に)

- Home、Dashboard、ログイン画面など主要画面の背景表現を確認する
- 薬物・違法性を連想させる画像表現を避ける
- 暗色UIの雰囲気は維持する

## 仕様（確定）

- 背景画像は抽象的で落ち着いた表現にする
- 葉や違法性を連想させるモチーフは使わない
- 既存の暗色UI、カード、煙の演出は大きく崩さない
- class名なども内容に合わせ、誤解を招く名前を避ける
- UIロジック、認証、記録、金額計算は変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `app/assets/images/*` / `app/assets/stylesheets/application.tailwind.css` / `app/views/home/index.html.erb` / `app/views/dashboard/index.html.erb` / `app/views/devise/sessions/new.html.erb`
<!-- 実装クリア: ISSUE-109
- [x] 就活向けの抽象背景画像に差し替える
- [x] 背景用class名を内容に合う名前へ変更する
- [x] 葉モチーフのCSS/SVG表現を削除する
- [x] Home、Dashboard、ログイン画面で背景が自然に表示されることを確認する
- [x] Docker 経由のCSS buildとテストが通ることを確認する
- [x] Playwrightで主要画面とconsole errorを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-109
- [x] 認証、記録、金額計算、購入処理を変更しない
- [x] UI全体を別デザインへ作り替えない
- [x] Git管理対象外の画像を参照しない
-->

## ゴール

<!-- 実装クリア: ISSUE-109
- [x] 就活用ポートフォリオとして見せやすい背景になっている
- [x] 主要画面の見た目が崩れていない
- [x] Docker 経由の確認が通る
-->

---

# ISSUE-110 READMEを就活用に整理する

## なぜ必要か

- READMEが実装前の想定やMVP検証寄りの表現を含んでおり、現在の実装内容とずれていたため
- 面接官や採用担当が、アプリの目的、機能、工夫、技術選定、設計意図を短時間で把握できるようにするため

## 必要なこと(簡易的に)

- 現在の実装済み機能とREADMEの内容を照らし合わせる
- MVPとして実装した機能と、今後実装予定の機能を分ける
- 就活用に、工夫した点や設計上の意図を読みやすく整理する

## 仕様（確定）

- README冒頭でサービス概要を伝える
- アプリURL、Figma、画面イメージ、機能、工夫、技術スタック、ER図、セットアップを整理する
- 「今後の展望」ではなく「今後実装予定の機能」として目次にも反映する
- 実験的な検証表現だけに寄せず、卒業制作として工夫した点も分かる文章にする
- ローカル実行手順はDocker前提で書く

## やること(コードレベル)

- **変更点（ファイル）**: `README.md`
<!-- 実装クリア: ISSUE-110
- [x] README全体を就活用の構成に整理する
- [x] サービス概要、背景、主要機能、画面イメージ、工夫点を追加する
- [x] 技術スタックに「どこで使ったか」「なぜ使ったか」が伝わるようにする
- [x] ER図と主要テーブルの説明を置く
- [x] Docker前提のローカルセットアップを書く
- [x] 今後実装予定の機能を目次に反映する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-110
- [x] 実装済みでない機能を、実装済みのように書かない
- [x] ローカル直実行前提のコマンドにしない
- [x] 秘密情報、個人メールアドレス、APIキーを書かない
-->

## ゴール

<!-- 実装クリア: ISSUE-110
- [x] READMEだけでChillSmokeの概要と工夫点が伝わる
- [x] 現在の実装内容とREADMEに大きなズレがない
- [x] 就活用ポートフォリオとして見せやすい構成になっている
-->

---

# ISSUE-111 READMEの画面イメージを画像として表示する

## なぜ必要か

- 画面イメージがリンク文字だけだと、読む人が1つずつクリックして確認する必要があり、README上でアプリの雰囲気が伝わりにくいため
- 就活用READMEでは、開いた瞬間に主要画面の見た目を確認できる方が親切なため

## 必要なこと(簡易的に)

- Gyazoの画像URLをMarkdownの画像記法で埋め込む
- クリックすればGyazoページも開けるようにする
- READMEが縦に長くなりすぎないよう、表で整理する

## 仕様（確定）

- ダッシュボード、喫煙スケジュール、喫煙カレンダー、ウィッシュリスト、ユーザー設定をREADME上に画像表示する
- ER図もREADME上に画像表示する
- 画像はクリック可能にし、元のGyazoページへ遷移できるようにする
- Gitに画像ファイルを追加せず、Gyazo画像URLを使う
- README以外は変更しない

## やること(コードレベル)

- **変更点（ファイル）**: `README.md`
<!-- 実装クリア: ISSUE-111
- [x] 画面イメージのリンク文字をMarkdown画像に変更する
- [x] 2列の表で主要画面を見やすく並べる
- [x] ユーザー設定の画像を単独行で表示する
- [x] ER図も画像として表示する
- [x] `git diff --check` でMarkdownの不要な空白がないことを確認する
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-111
- [x] README以外の実装ファイルを変更しない
- [x] 画像ファイルをリポジトリに追加しない
- [x] 既存のREADME構成を大きく崩さない
-->

## ゴール

<!-- 実装クリア: ISSUE-111
- [x] README上で主要画面が画像として直接確認できる
- [x] 画像クリックで元ページも確認できる
- [x] docs-onlyの差分としてPRに出せる
-->

---

# ISSUE-112 Resendでお問い合わせメール送信とパスワードリセットを再導入する

## なぜ必要か

- 独自ドメインとResend APIキーの準備ができたため、SMTPなしで問い合わせメール送信とDeviseのパスワードリセットメール送信を実装できるため
- 現在のX導線だけでは、Xアカウントを持たないユーザーやメールで連絡したいユーザーにとって使いづらいため
- 現在はSMTP未設定を理由にDeviseのパスワード再設定ルートを無効化しているため、パスワードを忘れたユーザーが自力で復旧できないため
- 以前のSMTP未設定による `localhost:25` エラーを避け、外部メールAPI経由で安全に送信するため

## 必要なこと(簡易的に)

- Resendで送信ドメインの認証が完了していること
- Resend APIキーを取得済みであること
- APIキー、受信先、送信元はコードに直書きせず、環境変数で設定すること
- Render本番環境にも同じ環境変数を登録すること
- DeviseのパスワードリセットメールもResend経由で送信できるようにすること

## 仕様（確定）

- ResendをRailsのメール送信基盤として設定し、問い合わせメールとDeviseメールの両方で使う
- Home画面 footer の「お問い合わせ」から問い合わせフォームを開けるようにする
- 入力項目は次の3つ
  - 名前: 必須
  - メールアドレス: 必須、メール形式
  - 内容: 必須
- 問い合わせ内容はDB保存しない
- メール送信はResend経由にする
- APIキーは `RESEND_API_KEY` 環境変数から読む
- 受信先は `CONTACT_MAIL_TO` 環境変数から読む
- 問い合わせ送信元は `CONTACT_MAIL_FROM` 環境変数から読む
- Deviseメール送信元は `DEVISE_MAILER_FROM` 環境変数から読む
- `CONTACT_MAIL_FROM` と `DEVISE_MAILER_FROM` はResendで認証済みの独自ドメイン配下のメールアドレスにする
- 入力されたメールアドレスは `reply_to` に設定し、返信しやすくする
- Deviseのパスワード再設定ルートを復活させる
- ログイン画面から「パスワードをお忘れですか？」の導線を使えるようにする
- パスワード再設定メールには、本番URLの再設定リンクが含まれるようにする
- 環境変数不足やResend送信失敗時は、500画面ではなく画面上のエラーメッセージで案内する
- 開発・テストでは実メール送信を避け、ActionMailerのtest delivery等で確認する
- X導線は代替連絡先としてフォーム内またはエラー時案内に残してよい

## やること(コードレベル)

- **変更点（ファイル）**: `Gemfile` / `config/initializers/*` / `config/environments/production.rb` / `config/environments/development.rb` / `config/routes.rb` / `config/initializers/devise.rb` / `app/controllers/contacts_controller.rb` / `app/models/contact_form.rb` / `app/mailers/contact_mailer.rb` / `app/views/contact_mailer/*` / `app/views/home/index.html.erb` / `app/views/devise/shared/_links.html.erb` / `test/*` / 必要に応じて `README.md`
<!-- 実装クリア: ISSUE-112
- [x] Resend公式SDKまたはAction Mailer delivery methodの導入方針を確認する
- [x] Resend用のgemを追加する場合はDocker経由でbundle installする
- [x] `RESEND_API_KEY` を環境変数から読む初期化設定を追加する
- [x] productionでResend経由送信になるようにする
- [x] productionのhost設定を本番URLに合わせ、Deviseメール内リンクが `https://chillsmoke.onrender.com/` になるようにする
- [x] test環境では実送信せず、`ActionMailer::Base.deliveries` で確認できる状態にする
- [x] Deviseのパスワード再設定を復活させる
  - [x] `devise_for :users, skip: :passwords` を見直し、passwords route を使えるようにする
  - [x] ログイン画面またはDevise shared linksに再設定導線を戻す
  - [x] `DEVISE_MAILER_FROM` をDeviseの送信元として設定する
  - [x] 再設定メールに正しいURLが入ることを確認する
  - [x] 再設定画面でパスワードを変更できることを確認する
- [x] `ContactForm` を復活または作成する
  - [x] `name`, `email`, `message` を扱う
  - [x] presence validation を設定する
  - [x] email形式 validation を設定する
- [x] `ContactsController#create` を作る
  - [x] 正常時は `ContactMailer` で送信する
  - [x] validation error時は入力内容とエラーを表示する
  - [x] Resend送信失敗時は500にせず、問い合わせ送信に失敗した旨を表示する
- [x] `ContactMailer` を作る
  - [x] 宛先は `CONTACT_MAIL_TO`
  - [x] 送信元は `CONTACT_MAIL_FROM`
  - [x] 件名は `ChillSmoke お問い合わせ`
  - [x] 本文に名前、メールアドレス、内容を含める
  - [x] `reply_to` に入力メールアドレスを設定する
- [x] Home画面の問い合わせPOPUPをフォームに戻す
  - [x] 入力エラーが分かる
  - [x] 送信完了が分かる
  - [x] スマホ幅でも入力欄とボタンが崩れない
- [x] Renderに設定する必要がある環境変数をREADMEまたは運用メモに書く
- [x] controller/model/mailer test を追加または更新する
  - [x] 正常送信時に宛先、送信元、reply_to、件名、本文が正しい
  - [x] 必須項目不足で送信されない
  - [x] email形式不正で送信されない
  - [x] 環境変数不足時に500にならない
  - [x] パスワード再設定メールがResend送信設定を前提に作成される
  - [x] パスワード再設定メールに本番URL形式のリンクが含まれる
-->

## 変更してはいけないこと

<!-- 実装クリア: ISSUE-112
- [x] `RESEND_API_KEY`、個人メールアドレス、SMTPパスワードをリポジトリに書かない
- [x] 問い合わせ内容をDB保存しない
- [x] Deviseのパスワード再設定以外の認証仕様を勝手に変更しない
- [x] Deviseの確認メール、ロック解除メールなど、このMVPで使っていないメール機能を勝手に有効化しない
- [x] 認証、ダッシュボード、記録、金額計算、購入処理を変更しない
- [x] 本番で未設定の環境変数により500画面を出さない
-->

## ゴール

<!-- 実装クリア: ISSUE-112
- [x] Home画面 footer の「お問い合わせ」からフォームを開ける
- [x] 名前、メールアドレス、内容を入力してResend経由でメール送信できる
- [x] ログイン画面からパスワード再設定メールを送信できる
- [x] パスワード再設定メールのリンクからパスワードを変更できる
- [x] APIキー、問い合わせ送信元、Devise送信元、受信先は環境変数で管理される
- [x] validation error と送信失敗が日本語で分かりやすく表示される
- [x] Docker 経由のテストが通る
- [x] Playwright/MCPで問い合わせフォームの表示、入力、validation error、パスワード再設定導線を確認し、console error がない
-->
