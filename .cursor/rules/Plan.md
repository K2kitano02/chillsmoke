# ChillSmoke 実装用プラン（MVP）

このファイルは「実装時に迷わない」ことを目的に、仕様・データ・画面・ルーティング・実装順を1つにまとめたもの。

## 1. アプリ概要

ChillSmoke は、禁煙ではなく減煙を段階的に支援する習慣化アプリ。  
毎日の喫煙本数を記録し、目標と比較しながら減煙を続ける。  
減煙によって節約できた金額を可視化し、ウィッシュリストと紐づけることでモチベーション維持を図る。

### コンセプト
- 禁煙よりも、まずは減煙
- 習慣化を重視
- ご褒美設計で継続しやすくする
- シンプルなUIで毎日使いやすくする

## 2. 想定ユーザー
- 禁煙に何度も失敗してきた人
- まずは本数を減らしたい人
- 節約目的でタバコを減らしたい人
- 減煙を習慣として続けたい人

## 3. MVPの確定仕様（今回の前提）
- 認証は **Devise** を採用
- **鬼モード（is_oni_mode）はMVPで実装**
- アプリのタイムゾーンは **`config.time_zone = "Tokyo"`**（`Time.zone.today` 等の日付境界の基準。TODO ISSUE-00）
- **ウィッシュリストの画像は MVP では扱わない**（`user_wishlists` に `image` カラムは置かない。外部URLのみの案は拡張時に再検討。TODO ISSUE-80）

## 4. MVPで実装する機能（一覧）
### 認証/導線
- ユーザー登録
- ログイン / ログアウト
- 保護ページのログイン必須化（未ログインは認証画面へ）
- `root("/")` は未ログインでも閲覧可能なアプリ説明画面 / オンボーディングとする
- 初回ログイン時に初期設定へ誘導（設定未作成の場合）

### 初期設定/設定変更
- 初期設定（`user_settings`）
  - 1日の基準本数（baseline）
  - 目標本数（target）
  - 1箱の価格（pack_price）
  - 1箱の本数（cigarettes_per_pack、デフォルト20）
  - 鬼モード（is_oni_mode）
- 設定変更
  - baseline / target / pack_price / cigarettes_per_pack / is_oni_mode

### 喫煙記録/閲覧
- 喫煙本数の記録（当日は主に +1 で加算。**補正**は日付指定フォームで**当日・過去日**の本数を直接保存可能、TODO **ISSUE-33**）
- 今日の喫煙本数表示
- 目標本数表示（当日の目標）
- 残り本数表示（`max(0, target - today_count)`）
- カレンダーによる喫煙履歴閲覧
- カレンダー上での達成 / 未達表示
- カレンダーから過去日の編集（その日の本数を修正）
- 継続日数表示（後述のロジック）

### 節約/ご褒美
- 節約金額表示（累計、保存せず計算）
- 使用可能金額表示（累計節約額 - 累計使用額）
- ウィッシュリスト
  - 登録 / 閲覧 / 編集 / 削除
  - 購入（残高チェック→購入履歴作成→購入済みに更新）
  - 購入履歴閲覧（MVPでは wishlist につき1件）

### スケジュール
- スケジュール設定（固定時間＋ラベル＋ON/OFF）
- 1スケジュール = 1本として、当日の喫煙記録へ反映できる
  - 反映後にズレた場合は、カレンダー編集で修正する

## 5. データ設計（ERの読み替えメモ）
ER図は `@.cursor/rules/ER.md` を正とする。MVPの実装上のポイントだけここに残す。

### users（Devise）
- `password_digest` ではなく **Deviseのカラム**（例: `encrypted_password` 等）を使用する想定

### user_settings（1ユーザー1設定）
- `user_id` は unique
- バリデーション例
  - baseline, target, pack_price, cigarettes_per_pack は正の整数
  - baseline >= target を必須（「基準より目標が多い」は節約の意味が薄い）

### user_smoking_logs（1日1レコード）
- `[user_id, smoked_on]` unique
- `smoking_count` を当日加算していく
- snapshot（後から設定が変わっても、当日の計算が再現できるように保持）— **5項目**（`@.cursor/rules/ER.md` の `user_smoking_logs` と一致）
  - `target_daily_cigarette_count_snapshot`
  - `baseline_daily_cigarette_count_snapshot`
  - `pack_price_snapshot`
  - `cigarettes_per_pack_snapshot`
  - `is_oni_mode_snapshot`

### user_wishlists / user_purchase_histories
- MVPでは「wishlist1件につき購入履歴1件」想定
- **画像カラム・画像アップロードは持たない**（MVP）
- 購入時は残高不足や重複購入を防ぐ（トランザクション）

## 6. 喫煙記録ロジック（MVP仕様）
### 基本方針
- 1日1レコード（`user_smoking_logs`）
- その日の本数を加算していく（当日 +1）
- 本数の**修正**・**未記録日のあとから登録**は**日付指定の本数フォーム**（`user_smoking_logs` の新規/更新、TODO **ISSUE-33**）で行い、**カレンダー・日付詳細**から同フォームへ導線を張る
- **snapshot（`user_smoking_logs` の5項目）**: 行の**新規作成時**にだけ `user_settings` からコピーする。値は**保存操作の時点の現在設定**であり、**その日付の当時設定の再現ではない**。`UserSetting` の変更履歴は持たず、当時復元も今後実装しない。**既存ログの本数修正**では `*_snapshot` は変更しない（過去日の遡及作成も「新規作成」にあたる）
- 未記録日は**ログ行が無い日**（その日の日次節約・累計集計に行が存在しない）
- 当日は継続日数に含めない

### 日付指定の本数フォーム（当日・過去日・新規/更新、TODO ISSUE-33）
- 対象日は**過去日および当日**（`smoked_on <= Time.zone.today`）。**未来日（`smoked_on > Time.zone.today`）は保存不可**とし、フォームにエラーを出す
- 日付の境界判定は必ず **`Time.zone.today`** を基準にする（セクション3のタイムゾーン設定と整合）
- 当日の**通常**の記録は**+1**（`increment` 等）を主導線とする。一方、記録ミスやスケジュール反映後のズレの**補正**のため、**当日**も同じ本数フォームから `smoking_count` を**直接保存**できる
- **GET（`new` / `edit` の表示・日付詳細の表示）だけ**では、当日・過去日を問わず `user_smoking_logs` 行を **`create` しない**（**保存操作**でのみ行を作る/更新する）
- **未記録日**に初めて保存するとき: **新規行**とし、保存リクエスト時点の `current_user.user_setting` から **snapshot 5項目**をコピーする
- **既存ログ**の更新: `smoking_count` 等の本数まわりのみ更新し、**`*_snapshot` は変更しない**

### カレンダー表示
- デフォルトでその日の喫煙本数を表示
- 達成/未達の判定
  - 緑：目標達成（`smoking_count <= target_daily_cigarette_count_snapshot`）
  - 赤：未達（`smoking_count > target_daily_cigarette_count_snapshot`）
- 日付をタップすると、その日の詳細（本数/目標/節約）と編集へ

### 継続日数（連続達成）
- 対象: 過去日（当日を除外）
- ルール
  - カレンダー上で**日付を1日ずつ連続して過去へ遡る**（**ログ行がない日を飛ばさず**、欠けている日で連続が途切れる）
  - **その日にログ行が無い**、または **ログはあるが目標未達** の日に達したら連続を途切れさせる（カウント終了）
  - 例: 昨日が未記録・一昨日だけ達成ログがある場合、連続は0
- 実装イメージ
  - `today - 1` から1日ずつ `smoked_on` を探り、ログ欠番または未達で break

## 7. 節約金額と残高（計算仕様）
### 節約金額（保存しない）
- 日次節約本数
  - `saved_cigs = max(0, baseline_snapshot - smoking_count)`
- 鬼モード（MVPで実装）
  - `is_oni_mode == true` かつ `smoking_count > target_daily_cigarette_count_snapshot` の日は `saved_cigs = 0`（その日は節約が増えない）
- 日次節約金額
  - `saved_yen = floor(saved_cigs * pack_price_snapshot / cigarettes_per_pack)`
- 累計節約額（**確定・昨日まで**）
  - `smoked_on < Time.zone.today` のログのみを対象に `sum(saved_yen)`（**当日分は累計に含めない**）
- 今日の節約
  - **見込み**として別ロジックで `saved_yen` を算出し、**別枠で表示**する（例: 累計 12,000円（昨日まで）／今日の節約見込み 300円）。**継続日数（当日除外）**と同様、当日は確定した累計の対象外とする考え方で整合する

### 使用可能金額
- `usable_yen = cumulative_saved_yen - cumulative_spent_yen`（**`cumulative_saved_yen` は上記の確定累計のみ。今日の見込みは残高に含めない**）
- `cumulative_spent_yen` は `user_purchase_histories.amount` の合計

### ウィッシュリスト購入
- 購入対象の wishlist は **必ず** `current_user.user_wishlists.find(params[:id])` で取得する（スコープなしの `UserWishlist.find` は禁止。TODO ISSUE-91）
- `wishlist.price` をそのまま使用額にする
- MVPでは購入履歴は1件想定（2回目購入は不可）
- 購入時チェック
  - 残高不足ならエラー
  - すでに購入済みならエラー

## 8. スケジュール機能（MVP仕様）
### 役割
減煙の習慣化支援。喫煙する時間を設定しておくことで、記録の手間を減らす。

### ロジック
- 1スケジュール = 1本
- スケジュールは実際に喫煙記録へ反映する（当日に加算）
- **反映済みの管理は ER の `user_schedule_reflections` に従う**: `user_schedule_id` と **`reflected_on`（反映した日付）**の組で1件ずつ記録し、**`(user_schedule_id, reflected_on)`ユニーク**とする（`@.cursor/rules/ER.md`）。**件数差分のみ**での管理は同日の入れ替えで漏れるため**行わない**（TODO ISSUE-76 の方式Bに相当）
- **反映処理の安全性（ISSUE-76）**: **`transaction` 1回**で、今日ログの **取得または新規作成（そのとき `user_setting` から snapshot 5項目を ISSUE-31 と同一にコピー）** → 当日行の **`with_lock`** → 未反映スケジュール取得 → **各スケジュールごとに `user_schedule_reflections` の INSERT 成功後にのみ** `smoking_count` を加算、までを **同一トランザクション内・最後に1回コミット**（途中でコミットしない）。**ユニーク制約違反**は二重反映として **加算しない**（**冪等**・並行実行でも水増ししない）。`UserSchedule` に **`has_many :user_schedule_reflections, dependent: :destroy`**、`UserScheduleReflection` に **`belongs_to :user_schedule`** を定義し、スケジュール削除時に **連鎖削除**して孤立データを残さない
- 実態とズレた場合は、カレンダー編集で修正する

例
- 昼休み
- 仕事終わり

## 9. 画面（MVP最小構成）
- 認証（Devise）: sign up / sign in
- 初期設定: 設定作成（初回必須）
- ダッシュボード
  - 今日の本数 / 目標 / 残り / **累計節約（昨日までの確定）** / **今日の節約見込み** / 残高（確定累計−使用、見込みは残高に含めない） / 継続日数
  - 当日の `user_smoking_logs` 行は **+1記録・スケジュール反映・カレンダー保存・過去日手動入力**など **保存操作時のみ** DB に `create` する。**画面表示（GET）だけでは行を作らない**
  - 当日行が無いときは **本数0の仮想表示**（`save` しない）とし、未記録のまま snapshot 付きレコードが自動生成されて節約が水増しされないようにする
  - 「+1で記録」ボタン
  - （任意）スケジュール反映ボタン
- カレンダー: 月表示 + 色分け + 詳細/編集 - **日付詳細**は **日付ベースのURL**のみ使う（ログIDに依存しない）。例: `GET /user_smoking_logs/by_date?date=YYYY-MM-DD`、または `GET /user_smoking_logs/:date`（`:date` に `YYYY-MM-DD` 制約を付け、`show :id` と競合しないようルート順を整理）
  - 指定日にログ行があればその内容を表示し、**なければ未記録**として詳細を表示（本数0・「未記録」等）。**未記録日の目標・節約は「―」**とし、**現在の `UserSetting` で補完しない**（snapshot のある日のみ日次式で表示）
  - **日付詳細の GET（表示）だけ**では `user_smoking_logs` を **`create` しない**（ダッシュボードと同一原則）
  - カレンダーの日付クリックは **必ず上記ルート**へ遷移する
- 設定: 設定変更 + スケジュールCRUD
- ウィッシュリスト: 一覧/詳細/新規/編集
- 購入: 確認→購入→履歴表示

## 10. 実装順（おすすめ）
1. Rails初期化（Tailwind導入、共通レイアウト、デプロイ準備）
2. Devise導入（User作成、保護ページのログイン必須化）
3. `UserSetting`（初回導線＋バリデーション）
4. `UserSmokingLog`（当日加算、snapshot、カレンダー表示、過去日編集）
5. 集計/計算（節約/残高/継続日数、鬼モード反映）
6. `UserSchedule`（CRUD＋当日反映）
7. `UserWishlist` / `UserPurchaseHistory`（CRUD＋購入トランザクション）
8. 仕上げ（UX、エラーハンドリング、最低限テスト）

---

更新メモ:
- ERは `@.cursor/rules/ER.md` を参照（Devise採用のため users 定義はER側もDeviseカラムに合わせて更新する）
- 本数の日付指定フォーム（当日・過去日・未来日不可・GETでは行を作らない等）は **TODO ISSUE-33** の「当日扱い・日付境界（確定）」と揃えている