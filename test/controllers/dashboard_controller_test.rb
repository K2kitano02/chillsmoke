require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
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
  end
end
