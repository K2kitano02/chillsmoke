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
- [ ] `docker compose up` でWeb+DBが起動し、`rails db:create db:migrate` が成功する
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
- [x] 判定メソッド（model or helper）を用意（`UserSmokingLog#met_daily_target?` / `ApplicationHelper#calendar_day_link_classes`）
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
- [ ] 上記「仕様（確定）」どおり **日付ベース**のルートを定義する（**カレンダー導線で `GET /user_smoking_logs/:id` 型を使わない**）
- [ ] 指定日のログがあればその本数・snapshot ベースの目標・節約を表示。**無い場合**は未記録として本数0等を示し、**目標・節約は「―」**（**`UserSetting` で補完しない**）
- [ ] **本数修正**へのリンクを置く（ISSUE-33 の **new（日付指定）/ edit** のどちらでも同じフォームに着地できるようにする）

## ゴール

- [ ] **未記録日**でも日付URLから詳細が開ける
- [ ] **未記録日**の目標・節約が **「―」で一貫**し、**`UserSetting` フォールバックが無い**
- [ ] カレンダー→詳細→（未記録を含む）本数修正の導線が機能する

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
- [ ] 1日分: `saved_cigs = [0, baseline_snapshot - smoking_count].max`、鬼モードは ISSUE-61 どおり
- [ ] `saved_yen = (saved_cigs * pack_price_snapshot / cigarettes_per_pack_snapshot).floor`
- [ ] **累計（確定）**: `smoked_on < Time.zone.today` の行のみ集計
- [ ] **今日の見込み**: `smoked_on == Time.zone.today` の行があればそれを、なければ仮想0相当で別算出（累計ロジックと分離）

## ゴール

- [ ] 当日の途中状態でも **累計が過大表示**されない（累計に当日が混入しない）
- [ ] 今日の金額が **見込み**として **別枠**で表示でき、**累計（昨日まで確定）**と混同されない

---

# ISSUE-51 使用可能金額（残高）算出ロジック実装

## なぜ必要か

- 「貯まった（節約した）お金で買う」体験の前提として残高が必要

## 必要なこと(簡易的に)

- ISSUE-50完了（節約額が出せる）
- purchase未実装でも0扱いにする方針

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（例: `Money::BalanceQuery`）
- [ ] **残高の分子**は ISSUE-50 の **累計節約（確定・昨日まで）**のみを使う（**節約見込みは残高に含めない**）
- [ ] `cumulative_spent_yen = current_user.user_purchase_histories.sum(:amount)`（関連実装後に）
- [ ] 一旦purchaseが未実装でも0扱いで表示できるようにする

## ゴール

- [ ] 節約額と組み合わせて残高が表示できる（見込みで使える金額が水増しされない）

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
- [ ] **上記「仕様（確定）」どおり**に連続日数を算出する（達成/未達の定義は ISSUE-41 と同じ）
- [ ] 例: **昨日にログ行が無い**場合、連続は **0**

## ゴール

- [ ] 例データで期待通りの連続数になる

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
- [ ] **当日**は ISSUE-31 に従い、DB のログ行 **または** `smoking_count = 0` の仮想状態を表示する（**`index` 表示だけではログ行を create しない**）
- [ ] **節約表示**は ISSUE-50 どおり **二系統**に分ける:**累計節約（昨日までの確定）** と **今日の節約見込み**（ラベルで見込みと明示）
- [ ] **残高**は ISSUE-51 どおり、**確定累計 − 使用累計**（今日の見込みは残高に含めない）
- [ ] 継続日数（ISSUE-52・当日除外）とあわせて表示
- [x] 「+1で記録」ボタンを配置（ISSUE-32と接続）

## ゴール

- [ ] ログイン後にダッシュボードが表示され、指標が更新される
- [ ] 当日の途中でも **累計・残高が過大**にならない（見込みは別枠）

---

# ISSUE-60 鬼モードON/OFF UI（設定画面）

## なぜ必要か

- MVP要件の鬼モードをユーザーが切り替えられるようにするため

## 必要なこと(簡易的に)

- ISSUE-23完了（設定編集画面がある）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_settings/edit.html.erb`
- [ ] checkboxを設置、説明文を付ける（目標超過日は節約が増えない）

## ゴール

- [ ] ON/OFFが保存できる

---

# ISSUE-61 鬼モードの節約計算反映（目標超過日は節約加算0）

## なぜ必要か

- 鬼モードの価値（完璧主義向けの厳格ルール）を節約計算へ反映しないと意味がないため

## 必要なこと(簡易的に)

- ISSUE-50完了（節約計算）
- ISSUE-23/60（is_oni_modeが設定できる）

## やること(コードレベル)

- **変更点（ファイル）**: `app/services/*`（節約計算）
- [ ] `if is_oni_mode_snapshot && smoking_count > target_daily_cigarette_count_snapshot then saved_cigs = 0 end`
- [ ] 表示側（詳細/ダッシュボード）で反映後の値を使う

## ゴール

- [ ] 同一ログでも鬼モードONで節約額が0になるケースが再現できる

---

# ISSUE-70 UserScheduleテーブル/モデル作成

## なぜ必要か

- 「固定時間の喫煙をまとめて反映」するためのデータ土台が必要

## 必要なこと(簡易的に)

- ISSUE-10完了（User）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_schedule.rb` / `app/models/user.rb`
- [ ] migration作成（`user:references`, `scheduled_smoking_time:time`, `label`, `is_active default:true`）
- [ ] `User has_many :user_schedules, dependent: :destroy`
- [ ] **`UserSchedule has_many :user_schedule_reflections, dependent: :destroy`**（**`UserScheduleReflection` モデル・テーブル追加後**／ISSUE-76 と同時でよい）
- [ ] バリデーション（time presence 等）

## ゴール

- [ ] consoleでCRUDできる

---

# ISSUE-71 スケジュール一覧

## なぜ必要か

- 作成/編集/削除へ入る入口が必要なため（CRUDの起点）

## 必要なこと(簡易的に)

- ISSUE-70完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_schedules_controller.rb` / `app/views/user_schedules/index.html.erb`
- [ ] `resources :user_schedules` を追加（名前は任意）
- [ ] `index` で `current_user.user_schedules` を表示

## ゴール

- [ ] ログインユーザーのスケジュールだけが表示される

---

# ISSUE-72 スケジュール作成

## なぜ必要か

- スケジュールが登録できないと、反映機能（時短）が成立しないため

## 必要なこと(簡易的に)

- ISSUE-71完了（一覧/導線）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_schedules/new.html.erb` / `user_schedules_controller.rb`
- [ ] `new/create` 実装（本人紐付け）
- [ ] バリデーションエラー表示

## ゴール

- [ ] 作成後に一覧に表示される

---

# ISSUE-73 スケジュール編集

## なぜ必要か

- 時刻/ラベルは生活に合わせて変わるため、編集できる必要があるため

## 必要なこと(簡易的に)

- ISSUE-72完了（作成できる）

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_schedules/edit.html.erb`
- [ ] `edit/update` 実装（本人のみ）

## ゴール

- [ ] 更新が保存される

---

# ISSUE-74 スケジュール削除

## なぜ必要か

- 使わなくなったスケジュールを整理できないと運用が辛くなるため

## 必要なこと(簡易的に)

- ISSUE-71完了

## やること(コードレベル)

- **変更点（ファイル）**: `user_schedules_controller.rb`
- [ ] `destroy` 実装（本人のみ）
- [ ] 削除後リダイレクト

## ゴール

- [ ] 一覧から消える

---

# ISSUE-75 スケジュールON/OFF切替

## なぜ必要か

- 削除せずに「一時的に反映対象から外す」運用が必要なため

## 必要なこと(簡易的に)

- ISSUE-71完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `user_schedules_controller.rb` / `index.html.erb`
- [ ] member route（例: `PATCH /user_schedules/:id/toggle`）
- [ ] `is_active = !is_active` で保存

## ゴール

- [ ] OFFにすると「反映対象から外れる」準備ができる

---

# ISSUE-76 スケジュールを今日ログへ反映（1スケジュール=1本）

## なぜ必要か

- 「記録の手間を減らす」というスケジュール機能の価値をMVPで体験可能にするため

## 必要なこと(簡易的に)

- ISSUE-31（今日ログ）
- ISSUE-75（active判定）

## 仕様（確定・スケジュール反映方式）

- MVPでは **方式Bのみ**を採用する。**方式A・方式Cは採用しない**
- **方式B**: **`user_schedule_reflections`** により **スケジュールID × 日付（`reflected_on`）**ごとに「その日そのスケジュールは反映済み」を管理する。ER（`@.cursor/rules/ER.md`）どおり **`(user_schedule_id, reflected_on)` ユニーク**
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
- [ ] **1 つの `transaction` ブロック**で、当日ログ取得 or 作成（5 snapshot）→ `with_lock` → 未反映取得 → 加算 → reflection 作成までを行い、**途中でコミットしない**
- [ ] **上記「トランザクション境界」「重複防止」「モデル定義」に沿い**、**アクティブ**かつ **当日分の reflection 未作成**のスケジュールのみ本数へ反映する（**1スケジュール=1本**・**二重加算なし**）
- [ ] 当日ログを **無ければ ISSUE-31 の create 経路で新規作成（snapshot）し**、あれば取得し、**`with_lock`** してから未反映一覧・加算・reflection 作成を行う
- [ ] 反映ボタンをダッシュボードに置く（確認ダイアログ等は任意）

## ゴール

- [ ] 反映後に今日の本数が増える（OFFは除外）
- [ ] **同一 `(user_schedule_id, reflected_on)` で本数が二重に増えない**（複数タブ・連打含む）
- [ ] **スケジュール反映が完全に冪等**（再実行・連打で、既反映分の本数が水増ししない）
- [ ] **並行実行**（複数タブ・同時 POST）でも **UNIQUE 違反時は加算せず**、ログ・reflection の整合が壊れない
- [ ] **`UserSchedule` 削除時に `user_schedule_reflections` が孤立しない**（`dependent: :destroy`）
- [ ] 実装者が **トランザクション境界と処理順**を TODO / コードのどちらかで迷わない

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
- [ ] migration（`user:references`, `name`, `price`, `memo`, `is_purchased default:false`）— **`image` は含めない**（上記「画像（MVP・確定）」）
- [ ] `User has_many :user_wishlists, dependent: :destroy`
- [ ] バリデーション（name presence, price > 0）

## ゴール

- [ ] consoleでCRUDできる
- [ ] **画像仕様（案A）に沿い**、実装者が image の要否で迷わない

---

# ISSUE-81 ウィッシュリスト一覧

## なぜ必要か

- 登録した「欲しいもの」を俯瞰し、次の行動（詳細/購入）へ進む入口が必要

## 必要なこと(簡易的に)

- ISSUE-80完了

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/user_wishlists_controller.rb` / `app/views/user_wishlists/index.html.erb`
- [ ] `resources :user_wishlists`
- [ ] `index` 実装（本人のみ）

## ゴール

- [ ] 一覧表示できる

---

# ISSUE-82 ウィッシュリスト詳細

## なぜ必要か

- 購入判断やメモ確認のために、1件の情報をまとまって見れる必要があるため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `app/views/user_wishlists/show.html.erb`
- [ ] `show` 実装（本人のみ）
- [ ] 購入ボタン（購入済みは非表示/disabled）

## ゴール

- [ ] 詳細表示できる

---

# ISSUE-83 ウィッシュリスト作成

## なぜ必要か

- 欲しいものが登録できないと「節約→ご褒美」の体験が成立しないため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `new.html.erb` / `create`
- [ ] `new/create` 実装
- [ ] フォーム（name/price/memo）

## ゴール

- [ ] 作成後に一覧/詳細へ

---

# ISSUE-84 ウィッシュリスト編集

## なぜ必要か

- 価格やメモは後から変わるため、編集できる必要があるため

## 必要なこと(簡易的に)

- ISSUE-83完了

## やること(コードレベル)

- **変更点（ファイル）**: `edit.html.erb` / `update`
- [ ] `edit/update` 実装

## ゴール

- [ ] 更新が保存される

---

# ISSUE-85 ウィッシュリスト削除

## なぜ必要か

- 不要になった項目を整理できないと、運用が辛くなるため

## 必要なこと(簡易的に)

- ISSUE-81完了

## やること(コードレベル)

- **変更点（ファイル）**: `destroy`
- [ ] `destroy` 実装

## ゴール

- [ ] 一覧から消える

---

# ISSUE-90 UserPurchaseHistoryテーブル/モデル作成（wishlist 1件につき履歴1件）

## なぜ必要か

- 「購入＝使用した金額」を履歴として残し、残高計算（使用額）に使うため

## 必要なこと(簡易的に)

- ISSUE-80完了（wishlist）

## やること(コードレベル)

- **変更点（ファイル）**: `db/migrate/*` / `app/models/user_purchase_history.rb` / `app/models/user_wishlist.rb`
- [ ] migration（`user_wishlist:references{unique}`, `amount`, `purchased_at`）— **`user_id` は持たない**（利用者は wishlist 経由で特定する）
- [ ] `UserPurchaseHistory belongs_to :user_wishlist`
- [ ] `UserWishlist has_one :user_purchase_history, dependent: :destroy`
- [ ] `User has_many :user_purchase_histories, through: :user_wishlists`（残高算出で `current_user.user_purchase_histories` を使うため）
- [ ] DB制約（unique index on `user_wishlist_id`）

## ゴール

- [ ] 同一wishlistに2件目が作れない

---

# ISSUE-91 購入処理（残高チェック→履歴作成→購入済み更新、トランザクション）

## なぜ必要か

- MVPの「ご褒美で使う」体験の中心。整合性（残高・重複・更新順）を崩さず購入できる必要があるため

## スコープ（確定・不正アクセス防止）

- 購入対象の wishlist は **必ず** `current_user.user_wishlists.find(params[:id])` で取得する（**`UserWishlist.find(params[:id])` や、スコープなしの `find_by` 単体は禁止**）。他ユーザーの ID を指定されても **`ActiveRecord::RecordNotFound`** となり、操作できないこと

## 履歴の紐づけ（確定）

- **`user_purchase_histories` は `user_id` を持たず**、**`user_wishlist_id` のみ**で対応する wishlist に紐づく（ER `@.cursor/rules/ER.md` と一致）
- 購入履歴は **`UserPurchaseHistory.create!` を単体で呼ばない**。**取得済みの `wishlist` 経由**で作成し、`user_wishlist_id` の未設定・取り違えを防ぐ
- **実装例**：`wishlist.create_user_purchase_history!(amount: wishlist.price, purchased_at: Time.current)`

## 必要なこと(簡易的に)

- ISSUE-51（残高算出）完了
- ISSUE-90（購入履歴）完了
- ISSUE-82（詳細）に購入ボタンを置く想定

## やること(コードレベル)

- **変更点（ファイル）**: `config/routes.rb` / `app/controllers/purchases_controller.rb` / `app/services/*`（例: `Purchase::Create`）
- [ ] member route（例: `POST /user_wishlists/:id/purchase`）
- [ ] **上記「スコープ（確定）」どおり**、wishlist を `current_user.user_wishlists.find(params[:id])` で取得してから購入処理に入る
- [ ] **`ActiveRecord::Base.transaction` 内で、購入処理の先頭付近で `current_user.lock!`（または `User.lock.find` / `with_lock`）によりユーザ行をロック**し、**ロック取得後に**残高を再算出する（複数タブ・連打で同一の購入前残高を読み合い、合計が残高を超える履歴が作られるのを防ぐ）
- [ ] ロック後の **`usable_yen >= wishlist.price`** を満たさない場合はロールバックしエラー
- [ ] `wishlist.is_purchased`（必要なら `reload`）をチェックし、購入済みならエラー
- [ ] 同一 transaction 内で
  - [ ] **上記「履歴の紐づけ」どおり**、**取得済み `wishlist` 経由**で履歴を作成する（例：`wishlist.create_user_purchase_history!(amount: wishlist.price, purchased_at: Time.current)`）
  - [ ] `wishlist.update!(is_purchased: true)`

## ゴール

- [ ] 購入後に残高が減り、wishlistが購入済みになる
- [ ] **購入履歴が必ず対応する wishlist に紐づく**（`user_wishlist_id` が常に正しい）
- [ ] **並行リクエスト時も**残高を超える購入が成立しない
- [ ] **他ユーザーの wishlist ID では購入できない**（スコープどおり）

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

# ISSUE-99 仕上げ（バリデーション/テスト/デプロイ準備）

## なぜ必要か

- MVPとして最低限の品質（入力ミス時の分かりやすさ/壊れにくさ）と、公開可能状態を作るため

## 必要なこと(簡易的に)

- 主要機能が一通り実装済み

## やること(コードレベル)

- **変更点（ファイル）**: `spec/*` or `test/*` / `README.md` / Render設定
- [ ] 主要フォームのエラー表示統一（設定、ログ編集、wishlist）
- [ ] 最低限テスト
  - [ ] model: UserSetting validation、SavingsCalculator（鬼モード含む）
  - [ ] system: 登録→設定→+1記録→wishlist購入 のハッピーパス

## ゴール

- [ ] ローカルでハッピーパスが通る
