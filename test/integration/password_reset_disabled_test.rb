require "test_helper"

class PasswordResetDisabledTest < ActionDispatch::IntegrationTest
  test "ログイン画面にパスワード再設定リンクを表示しない" do
    get new_user_session_url

    assert_response :success
    assert_no_match(/パスワードを忘れた場合/, response.body)
  end

  test "パスワード再設定画面へアクセスできない" do
    get "/users/password/new"

    assert_response :not_found
  end
end
