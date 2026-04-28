# frozen_string_literal: true

require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  test "未ログインはカレンダーを開けない" do
    get calendar_url
    assert_redirected_to new_user_session_url
  end

  test "ログイン済みはカレンダーを表示でき、GET でログ行は増えない" do
    sign_in users(:one)

    assert_no_difference -> { UserSmokingLog.count } do
      get calendar_url
    end

    assert_response :success
    assert_select "h1", text: /喫煙記録カレンダー/
  end

  test "month 移動用 start_date パラメータがあってもログ行は増えない" do
    sign_in users(:one)
    anchor = (Time.zone.today - 2.months)

    assert_no_difference -> { UserSmokingLog.count } do
      get calendar_url(params: { start_date: anchor.strftime("%Y-%m-%d") })
    end

    assert_response :success
    assert_match anchor.year.to_s, response.body
  end

  test "カレンダーは達成日に緑・未達日に赤のスタイルを付ける（記録がある日のみ）" do
    sign_in users(:one)
    attrs = {
      target_daily_cigarette_count_snapshot: 5,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    }
    met_day = Time.zone.today - 12
    fail_day = Time.zone.today - 11
    month_start = met_day.beginning_of_month

    users(:one).user_smoking_logs.create!(attrs.merge(smoked_on: met_day, smoking_count: 4))
    users(:one).user_smoking_logs.create!(attrs.merge(smoked_on: fail_day, smoking_count: 7))

    assert_no_difference -> { UserSmokingLog.count } do
      get calendar_url(params: { start_date: month_start.strftime("%Y-%m-%d") })
    end

    assert_response :success
    assert_match "bg-emerald-50", response.body
    assert_match "border-emerald-200", response.body
    assert_match "bg-red-50", response.body
    assert_match "border-red-200", response.body
  end

  test "カレンダーは当月にログがなければ達成・未達の背景色を付けない" do
    sign_in users(:one)

    get calendar_url(params: { start_date: Time.zone.today.beginning_of_month.strftime("%Y-%m-%d") })
    assert_response :success
    assert_not_includes response.body, "bg-emerald-50"
    assert_not_includes response.body, "bg-red-50"
  end
end
