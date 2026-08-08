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

  test "節約額と目標達成で比較する本数の違いを表示する" do
    user = users(:one)
    sign_in user

    get report_url

    assert_response :success
    assert_match(/節約額の計算基準（現在の設定）/, response.body)
    assert_match(/基準本数/, response.body)
    assert_select "[data-report-current-baseline]", text: /#{user.user_setting.baseline_daily_cigarette_count}\s*本/
    assert_match(/現在の目標/, response.body)
    assert_select "[data-report-current-target]", text: /#{user.user_setting.target_daily_cigarette_count}\s*本/
    assert_match(/目標を超えても、基準本数より少なければ節約額は増えます/, response.body)
    assert_match(/過去日は、それぞれの記録時に保存した設定で計算します/, response.body)
  end

  test "ダッシュボードから減煙レポートへ移動できる" do
    sign_in users(:one)

    get dashboard_url

    assert_response :success
    assert_select "a[href=?]", report_path, text: "減煙レポート"
  end

  test "昨日までの7日分が揃うと平均と目標以内のペースを表示する" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.delete_all
    create_pace_logs(user, smoking_count: 3, target: 5)

    get report_url

    assert_response :success
    assert_select "h2", text: "直近7日間のペース"
    assert_match(/1日平均/, response.body)
    assert_select "p", text: /約\s*3\s*本/
    assert_match(/7日間では目標より14本少なく記録できました/, response.body)
    assert_match(/1日平均節約額/, response.body)
    assert_select "p", text: /425\s*円/
    assert_match(/30日間の節約ペース/, response.body)
    assert_select "p", text: /12,750\s*円/
    assert_match(/将来の成果を保証するものではありません/, response.body)
  end

  test "7日分の実績合計が目標合計を超えた場合のメッセージを表示する" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.delete_all
    create_pace_logs(user, smoking_count: 6, target: 5)

    get report_url

    assert_response :success
    assert_match(/7日間では目標より7本多い記録でした/, response.body)
  end

  test "7日分の実績合計と目標合計が同じ場合のメッセージを表示する" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.delete_all
    create_pace_logs(user, smoking_count: 5, target: 5)

    get report_url

    assert_response :success
    assert_match(/7日間では目標どおりの記録でした/, response.body)
  end

  test "昨日までの記録が不足している場合は必要な残り記録日数を表示する" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.delete_all
    create_pace_logs(user, smoking_count: 3, target: 5, days: 5)

    get report_url

    assert_response :success
    assert_match(/ペースを確認するまであと2日/, response.body)
    assert_no_match(/30日間の節約ペース/, response.body)
  end

  private

  def create_pace_logs(user, smoking_count:, target:, days: 7)
    days.times do |index|
      user.user_smoking_logs.create!(
        smoked_on: Time.zone.today - (index + 1).days,
        smoking_count: smoking_count,
        target_daily_cigarette_count_snapshot: target,
        baseline_daily_cigarette_count_snapshot: 20,
        pack_price_snapshot: 500,
        cigarettes_per_pack_snapshot: 20,
        is_oni_mode_snapshot: false
      )
    end
  end
end
