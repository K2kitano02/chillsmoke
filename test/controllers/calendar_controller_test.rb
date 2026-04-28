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
end
