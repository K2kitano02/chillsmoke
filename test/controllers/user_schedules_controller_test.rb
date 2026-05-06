# frozen_string_literal: true

require "test_helper"

class UserSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではスケジュール一覧を開けない" do
    get user_schedules_url

    assert_redirected_to new_user_session_url
  end

  test "UserSetting 未作成なら初期設定へリダイレクトされる" do
    sign_in users(:three)

    get user_schedules_url

    assert_redirected_to new_user_setting_url
  end

  test "ログインユーザーのスケジュールだけを一覧表示する" do
    sign_in users(:one)

    get user_schedules_url

    assert_response :success
    assert_select "h1", text: "喫煙スケジュール"
    assert_match(/08:00/, response.body)
    assert_match(/朝/, response.body)
    assert_match(/有効/, response.body)
    assert_no_match(/21:30/, response.body)
    assert_no_match(/夜/, response.body)
  end

  test "スケジュールがなければ空状態を表示する" do
    sign_in users(:one)
    users(:one).user_schedules.destroy_all

    get user_schedules_url

    assert_response :success
    assert_match(/まだスケジュールは登録されていません/, response.body)
  end
end
