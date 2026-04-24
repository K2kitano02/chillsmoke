require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "未ログインでも root（オンボーディング）を表示する" do
    get root_url
    assert_response :success
  end

  test "ログイン後も root を表示する" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
