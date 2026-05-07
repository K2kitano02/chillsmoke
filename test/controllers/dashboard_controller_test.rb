require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def log_attrs(smoking_count:, smoked_on:, target_daily_cigarette_count_snapshot: 5)
    {
      smoked_on: smoked_on,
      smoking_count: smoking_count,
      target_daily_cigarette_count_snapshot: target_daily_cigarette_count_snapshot,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    }
  end

  test "未ログインではサインインへリダイレクトされる" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test "UserSetting 未作成なら初期設定へリダイレクトされる" do
    sign_in users(:three)
    assert_nil users(:three).reload.user_setting

    get dashboard_url
    assert_redirected_to new_user_setting_url
  end

  test "設定済みユーザーはダッシュボードを表示できる" do
    sign_in users(:one)
    get dashboard_url
    assert_response :success
    assert_select "h1", text: "ダッシュボード"
    assert_match(/＋1で記録/, response.body)
    assert_select "a[href=?]", user_schedules_path, text: "喫煙スケジュール"
    assert_select "form[action=?]", increment_today_smoking_log_path
  end

  test "ダッシュボード表示だけでは当日ログを作らない" do
    sign_in users(:one)
    users(:one).user_smoking_logs.where(smoked_on: Time.zone.today).destroy_all

    assert_no_difference -> { UserSmokingLog.count } do
      get dashboard_url
    end

    assert_response :success
    assert_match(/今日の本数/, response.body)
    assert_match(/0本/, response.body)
    assert_match(/DBには保存していません/, response.body)
  end

  test "ダッシュボードに今日の本数と目標と残りを表示する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today, smoking_count: 2)
    )

    get dashboard_url

    assert_response :success
    assert_match(/今日の本数/, response.body)
    assert_match(/2本/, response.body)
    assert_match(/目標/, response.body)
    assert_match(/5本/, response.body)
    assert_match(/残り/, response.body)
    assert_match(/3本/, response.body)
  end

  test "節約と残高は昨日までの確定分と今日の見込みを分けて表示する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today - 1.day, smoking_count: 10)
    )
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today, smoking_count: 0)
    )

    get dashboard_url

    assert_response :success
    assert_match(/累計節約（昨日まで）/, response.body)
    assert_match(/250円/, response.body)
    assert_match(/今日の節約見込み/, response.body)
    assert_match(/500円/, response.body)
    assert_match(/使用可能金額/, response.body)
    assert_match(/今日の節約見込みは含めていません/, response.body)
  end

  test "鬼モード ON の目標超過日は節約と今日の見込みを 0 円で表示する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.create!(
      log_attrs(
        smoked_on: Time.zone.today - 1.day,
        smoking_count: 6
      ).merge(is_oni_mode_snapshot: true)
    )
    users(:one).user_smoking_logs.create!(
      log_attrs(
        smoked_on: Time.zone.today,
        smoking_count: 6
      ).merge(is_oni_mode_snapshot: true)
    )

    get dashboard_url

    assert_response :success
    assert_match(/累計節約（昨日まで）.*?0円/m, response.body)
    assert_match(/今日の節約見込み.*?0円/m, response.body)
    assert_match(/使用可能金額.*?0円/m, response.body)
  end

  test "継続日数は当日を含めず昨日までを表示する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today - 2.days, smoking_count: 4)
    )
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today - 1.day, smoking_count: 5)
    )
    users(:one).user_smoking_logs.create!(
      log_attrs(smoked_on: Time.zone.today, smoking_count: 0)
    )

    get dashboard_url

    assert_response :success
    assert_match(/継続日数/, response.body)
    assert_match(/2日/, response.body)
    assert_match(/昨日までの連続達成日数/, response.body)
  end
end
