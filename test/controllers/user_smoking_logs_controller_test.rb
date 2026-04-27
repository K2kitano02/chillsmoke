# frozen_string_literal: true

require "test_helper"

class UserSmokingLogsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインはサインインへリダイレクトされる" do
    post increment_today_smoking_log_url
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
end
