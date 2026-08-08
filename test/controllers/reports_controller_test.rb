require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではサインインへリダイレクトされる" do
    get report_url

    assert_redirected_to new_user_session_url
  end

  test "レポート表示だけでは喫煙ログを作成しない" do
    sign_in users(:one)
    users(:one).user_smoking_logs.where(smoked_on: Time.zone.today).destroy_all

    assert_no_difference -> { UserSmokingLog.count } do
      get report_url
    end

    assert_response :success
    assert_select "h1", text: "減煙レポート"
    assert_select "[role='tablist']"
    assert_select "button[role='tab'][aria-selected='true']", text: "喫煙本数"
    assert_select "button[role='tab'][aria-selected='false']", text: "節約額"
  end

  test "記録がない場合は記録を促すメッセージを表示する" do
    sign_in users(:one)
    users(:one).user_smoking_logs.delete_all

    get report_url

    assert_response :success
    assert_match(/まだグラフに表示できる記録がありません/, response.body)
  end

  test "今日だけ記録がある場合は節約額の確定記録がまだないことを表示する" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.delete_all
    user.user_smoking_logs.create!(
      {
        smoked_on: Time.zone.today,
        smoking_count: 2
      }.merge(UserSmokingLog.snapshot_attributes_from_user_setting(user.user_setting))
    )

    get report_url

    assert_response :success
    assert_match(/昨日までの確定記録はまだありません/, response.body)
    assert_match(/今日分は上の「今日の節約見込み」に表示しています/, response.body)
  end

  test "ダッシュボードから減煙レポートへ移動できる" do
    sign_in users(:one)

    get dashboard_url

    assert_response :success
    assert_select "a[href=?]", report_path, text: "減煙レポート"
  end
end
