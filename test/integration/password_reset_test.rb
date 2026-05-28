require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "ログイン画面にパスワード再設定リンクを表示する" do
    get new_user_session_url

    assert_response :success
    assert_match(/パスワードを忘れた場合/, response.body)
  end

  test "パスワード再設定メールを送信できる" do
    post user_password_url, params: {
      user: {
        email: users(:one).email
      }
    }

    assert_redirected_to new_user_session_url
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ users(:one).email ], mail.to
    assert_equal [ "no-reply@chillsmoke.example" ], mail.from
    assert_equal "パスワード再設定のご案内", mail.subject
    assert_match(%r{/users/password/edit\?reset_password_token=}, mail.body.encoded)
  end

  test "再設定トークンからパスワードを変更できる" do
    raw_token = users(:one).send_reset_password_instructions

    put user_password_url, params: {
      user: {
        reset_password_token: raw_token,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to dashboard_url
    assert users(:one).reload.valid_password?("newpassword123")
  end
end
