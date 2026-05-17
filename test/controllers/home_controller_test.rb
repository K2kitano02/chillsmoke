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

  test "Homeにfooter導線と利用規約POPUPの内容を表示する" do
    get root_url

    assert_response :success
    assert_select "footer nav[aria-label='フッター']"
    assert_select "button", text: "利用規約"
    assert_select "span", text: "プライバシーポリシー"
    assert_select "span", text: "お問い合わせ"
    assert_select "[role='dialog'][aria-labelledby='terms-title']"
    assert_select "#terms-title", text: "利用規約"
    assert_match(/医療行為、禁煙治療、専門的な健康指導を提供するものではありません/, response.body)
  end

  test "UserSetting 未作成なら root でも初期設定へリダイレクト（ISSUE-21）" do
    sign_in users(:three)
    get root_url
    assert_redirected_to new_user_setting_url
  end
end
