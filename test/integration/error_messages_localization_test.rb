# frozen_string_literal: true

require "test_helper"

class ErrorMessagesLocalizationTest < ActionDispatch::IntegrationTest
  test "model validation full_messages are shown in Japanese" do
    user = User.new
    user.valid?

    assert_includes user.errors.full_messages, "メールアドレスを入力してください"
    assert_includes user.errors.full_messages, "パスワードを入力してください"
    assert_includes user.errors.full_messages, "名前を入力してください"
    assert_not_includes user.errors.full_messages, "Email can't be blank"
    assert_not_includes user.errors.full_messages, "Password can't be blank"
    assert_not_includes user.errors.full_messages, "Name can't be blank"
  end

  test "numeric validation messages are shown in Japanese" do
    setting = UserSetting.new(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 3,
      pack_price: "abc",
      cigarettes_per_pack: nil
    )
    setting.valid?

    assert_includes setting.errors.full_messages, "1箱の価格は数値で入力してください"
    assert_includes setting.errors.full_messages, "1箱あたりの本数を入力してください"
    assert_includes setting.errors.full_messages, "基準本数は5以上の値にしてください"
    assert_not_includes setting.errors.full_messages, "Pack price is not a number"
    assert_not_includes setting.errors.full_messages, "Cigarettes per pack can't be blank"
  end

  test "devise login failure message is shown in Japanese" do
    post user_session_url, params: {
      user: {
        email: "missing@example.test",
        password: "wrongpassword"
      }
    }

    assert_response :unprocessable_content
    assert_match(/メールアドレスまたはパスワードが正しくありません。/, response.body)
    assert_no_match(/Email or password is invalid/, response.body)
  end
end
