require "test_helper"

class PasswordRevealButtonTest < ActionDispatch::IntegrationTest
  test "ログイン画面のパスワード欄に一時表示ボタンを表示する" do
    get new_user_session_url

    assert_response :success
    assert_select "div[data-controller='password-reveal']", 1
    assert_select "input[type='password'][data-password-reveal-target='input'][autocomplete='current-password']", 1
    assert_select "button[type='button'][aria-label='パスワードを押している間だけ表示']", 1
  end

  test "新規登録画面のパスワード欄と確認欄に一時表示ボタンを表示する" do
    get new_user_registration_url

    assert_response :success
    assert_select "div[data-controller='password-reveal']", 2
    assert_select "input[type='password'][data-password-reveal-target='input'][autocomplete='new-password']", 2
    assert_select "button[type='button'][aria-label$='を押している間だけ表示']", 2
  end

  test "アカウント編集画面の各パスワード欄に一時表示ボタンを表示する" do
    sign_in users(:one)

    get edit_user_registration_url

    assert_response :success
    assert_select "div[data-controller='password-reveal']", 3
    assert_select "input[type='password'][data-password-reveal-target='input']", 3
    assert_select "button[type='button'][aria-label$='を押している間だけ表示']", 3
  end
end
