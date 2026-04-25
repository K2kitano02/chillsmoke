require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "未ログインでも root（オンボーディング）を表示する" do
    get root_url
    assert_response :success
  end

  test "ログイン後も root を表示する（UserSetting あり）" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  test "UserSetting 未作成なら root でも初期設定へリダイレクト（ISSUE-21）" do
    sign_in users(:three)
    get root_url
    assert_redirected_to new_user_setting_url
  end
end

