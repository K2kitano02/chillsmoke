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

  test "Homeにfooter導線と規約系POPUPの内容を表示する" do
    get root_url

    assert_response :success
    assert_select "footer nav[aria-label='フッター']"
    assert_select "button", text: "利用規約"
    assert_select "button", text: "プライバシーポリシー"
    assert_select "button", text: "お問い合わせ"
    assert_select "[role='dialog'][aria-labelledby='terms-title']"
    assert_select "#terms-title", text: "利用規約"
    assert_match(/医療行為、禁煙治療、専門的な健康指導を提供するものではありません/, response.body)
    assert_select "[role='dialog'][aria-labelledby='privacy-title']"
    assert_select "#privacy-title", text: "プライバシーポリシー"
    assert_match(/名前、メールアドレス、喫煙記録、設定値、ウィッシュリスト、購入履歴/, response.body)
    assert_select "[role='dialog'][aria-labelledby='contact-title']"
    assert_select "#contact-title", text: "お問い合わせ"
    assert_select "form[action='#{contact_path}']"
    assert_select "input[name='contact_form[name]']"
    assert_select "input[name='contact_form[email]']"
    assert_select "textarea[name='contact_form[message]']"
    assert_select "a[href='https://x.com/K2kitano02']", text: "Xで連絡する"
  end

  test "UserSetting 未作成なら root でも初期設定へリダイレクト（ISSUE-21）" do
    sign_in users(:three)
    get root_url
    assert_redirected_to new_user_setting_url
  end
end
