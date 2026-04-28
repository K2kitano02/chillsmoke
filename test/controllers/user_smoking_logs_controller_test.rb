# frozen_string_literal: true

require "test_helper"

class UserSmokingLogsControllerTest < ActionDispatch::IntegrationTest
  def log_attrs
    {
      target_daily_cigarette_count_snapshot: 5,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    }
  end
  test "未ログインはサインインへリダイレクトされる" do
    post increment_today_smoking_log_url
    assert_redirected_to new_user_session_url
  end

  test "本数フォーム (new) も未ログインはサインインへ" do
    get new_user_smoking_log_url
    assert_redirected_to new_user_session_url
  end

  test "increment_today は当日行を作り smoking_count が 1 になる" do
    sign_in users(:one)

    assert_difference -> { UserSmokingLog.count }, 1 do
      post increment_today_smoking_log_url
    end
    assert_redirected_to dashboard_url
    assert_match(/記録しました/, flash[:notice].to_s)

    log = users(:one).user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 1, log.smoking_count
  end

  test "increment_today は既存行に加算する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.create!(
      smoked_on: Time.zone.today,
      smoking_count: 3,
      target_daily_cigarette_count_snapshot: 5,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    )

    assert_no_difference -> { UserSmokingLog.count } do
      post increment_today_smoking_log_url
    end
    assert_redirected_to dashboard_url

    log = users(:one).user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 4, log.smoking_count
  end

  test "連続 POST でカウントが積み上がる" do
    sign_in users(:one)
    3.times { post increment_today_smoking_log_url }
    log = users(:one).user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 3, log.smoking_count
  end

  # --- ISSUE-33: 日付指定の本数登録 ---

  test "new は GET ではログ行を作らない" do
    sign_in users(:one)
    day = Time.zone.today - 5.days
    assert_no_difference -> { UserSmokingLog.count } do
      get new_user_smoking_log_url(smoked_on: day.to_s)
    end
    assert_response :success
  end

  test "new は未来日クエリで 422 かつ本文にエラー" do
    sign_in users(:one)
    get new_user_smoking_log_url(smoked_on: (Time.zone.today + 1.day).to_s)
    assert_response :unprocessable_entity
    assert_match(/未来/, response.body)
  end

  test "new は該当日に既存ログがあれば edit へリダイレクト" do
    sign_in users(:one)
    day = Time.zone.today - 1.day
    existing = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 1))

    get new_user_smoking_log_url(smoked_on: day.to_s)
    assert_redirected_to edit_user_smoking_log_url(existing)
  end

  test "create は未記録の過去日に snapshot 付きで行を作る" do
    sign_in users(:one)
    day = Time.zone.today - 7.days
    assert_difference -> { UserSmokingLog.count }, 1 do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: day.to_s, smoking_count: "4" }
      }
    end
    assert_redirected_to edit_user_smoking_log_url(UserSmokingLog.order(:id).last)
    log = users(:one).user_smoking_logs.find_by!(smoked_on: day)
    assert_equal 4, log.smoking_count
    assert_equal users(:one).user_setting.target_daily_cigarette_count, log.target_daily_cigarette_count_snapshot
    assert_equal users(:one).user_setting.pack_price, log.pack_price_snapshot
  end

  test "create は未来日を保存せずエラー表示" do
    sign_in users(:one)
    assert_no_difference -> { UserSmokingLog.count } do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: (Time.zone.today + 1.day).to_s, smoking_count: 1 }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create は既存行の場合は本数のみ更新し snapshot は変えない" do
    sign_in users(:one)
    day = Time.zone.today - 2.days
    log = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 2))

    assert_no_difference -> { UserSmokingLog.count } do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: day.to_s, smoking_count: "9" }
      }
    end
    assert_redirected_to edit_user_smoking_log_url(log)
    log.reload
    assert_equal 9, log.smoking_count
    assert_equal 5, log.target_daily_cigarette_count_snapshot
  end

  test "update は smoking_count のみ変え snapshot は不変" do
    sign_in users(:one)
    day = Time.zone.today - 3.days
    log = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 1))

    patch user_smoking_log_url(log), params: { user_smoking_log: { smoking_count: 8 } }
    assert_redirected_to edit_user_smoking_log_url(log)
    log.reload
    assert_equal 8, log.smoking_count
    assert_equal 5, log.target_daily_cigarette_count_snapshot
  end

  test "他人のログ id の edit は 404" do
    sign_in users(:one)
    other_log = users(:two).user_smoking_logs.create!(log_attrs.merge(smoked_on: Time.zone.today - 1.day, smoking_count: 1))
    get edit_user_smoking_log_url(other_log)
    assert_response :not_found
  end

  test "create は本数が非数値のとき保存せず 422" do
    sign_in users(:one)
    day = Time.zone.today - 10.days
    assert_no_difference -> { UserSmokingLog.count } do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: day.to_s, smoking_count: "abc" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create は本数が非数値のとき既存行の本数を変えない" do
    sign_in users(:one)
    day = Time.zone.today - 11.days
    log = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 3))

    assert_no_difference -> { UserSmokingLog.count } do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: day.to_s, smoking_count: "xyz" }
      }
    end
    assert_response :unprocessable_entity
    assert_equal 3, log.reload.smoking_count
  end

  test "create は本数が空欄のとき 422 かつ新規行を作らない" do
    sign_in users(:one)
    day = Time.zone.today - 12.days
    assert_no_difference -> { UserSmokingLog.count } do
      post user_smoking_logs_url, params: {
        user_smoking_log: { smoked_on: day.to_s, smoking_count: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "update は本数が非数値のとき 422 かつ本数不変" do
    sign_in users(:one)
    day = Time.zone.today - 4.days
    log = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 6))
    before = log.reload.smoking_count
    patch user_smoking_log_url(log), params: { user_smoking_log: { smoking_count: "nope" } }
    assert_response :unprocessable_entity
    assert_equal before, log.reload.smoking_count
  end

  test "update は本数が空欄のとき 422 かつ本数不変" do
    sign_in users(:one)
    day = Time.zone.today - 5.days
    log = users(:one).user_smoking_logs.create!(log_attrs.merge(smoked_on: day, smoking_count: 7))
    before = log.reload.smoking_count
    patch user_smoking_log_url(log), params: { user_smoking_log: { smoking_count: "" } }
    assert_response :unprocessable_entity
    assert_equal before, log.reload.smoking_count
  end

  # --- ISSUE-42 / カレンダー連携: 日付詳細 ---

  test "by_date は GET でログ行を増やさない" do
    sign_in users(:one)
    day = Time.zone.today - 2.days
    assert_no_difference -> { UserSmokingLog.count } do
      get by_date_user_smoking_logs_url(date: day.strftime("%Y-%m-%d"))
    end
    assert_response :success
  end

  test "by_date はログがある日・未記録日の両方で 200" do
    sign_in users(:one)
    with_log = Time.zone.today - 1.day
    users(:one).user_smoking_logs.create!(
      log_attrs.merge(smoked_on: with_log, smoking_count: 3)
    )
    get by_date_user_smoking_logs_url(date: with_log.strftime("%Y-%m-%d"))
    assert_response :success
    assert_match(/3/, response.body)

    blank_day = Time.zone.today - 9.days
    get by_date_user_smoking_logs_url(date: blank_day.strftime("%Y-%m-%d"))
    assert_response :success
    assert_match(/未記録/, response.body)
  end

  test "by_date は他人のログは表示しない（その日は未記録扱い）" do
    sign_in users(:one)
    day = Time.zone.today - 3.days
    users(:two).user_smoking_logs.create!(
      log_attrs.merge(smoked_on: day, smoking_count: 99)
    )
    get by_date_user_smoking_logs_url(date: day.strftime("%Y-%m-%d"))
    assert_response :success
    assert_match(/未記録/, response.body)
    assert_no_match(/99\s*本/, response.body)
  end

  test "by_date は未来日をカレンダーへリダイレクト" do
    sign_in users(:one)
    future = Time.zone.today + 1.day
    get by_date_user_smoking_logs_url(date: future.strftime("%Y-%m-%d"))
    assert_redirected_to calendar_path
  end
end
