require "test_helper"

class RegistrationInitialSettingTest < ActionDispatch::IntegrationTest
  test "新規登録直後の遷移先は初期設定画面（ISSUE-21 ゴール）" do
    email = "issue21_new_#{SecureRandom.hex(4)}@example.test"

    assert_difference "User.count", 1 do
      post user_registration_url, params: {
        user: {
          email: email,
          name: "Issue21 User",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to new_user_setting_url
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "初期設定"
  end
end
