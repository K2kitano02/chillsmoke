# frozen_string_literal: true

require "test_helper"

class UserSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではスケジュール一覧を開けない" do
    get user_schedules_url

    assert_redirected_to new_user_session_url
  end

  test "UserSetting 未作成なら初期設定へリダイレクトされる" do
    sign_in users(:three)

    get user_schedules_url

    assert_redirected_to new_user_setting_url
  end

  test "ログインユーザーのスケジュールだけを一覧表示する" do
    sign_in users(:one)

    get user_schedules_url

    assert_response :success
    assert_select "h1", text: "喫煙スケジュール"
    assert_match(/08:00/, response.body)
    assert_match(/朝/, response.body)
    assert_match(/有効/, response.body)
    assert_no_match(/21:30/, response.body)
    assert_no_match(/夜/, response.body)
  end

  test "一覧から新規登録画面へ進める" do
    sign_in users(:one)

    get user_schedules_url

    assert_response :success
    assert_select "a[href=?]", new_user_schedule_path, text: "新規登録"
  end

  test "スケジュールがなければ空状態を表示する" do
    sign_in users(:one)
    users(:one).user_schedules.destroy_all

    get user_schedules_url

    assert_response :success
    assert_match(/まだスケジュールは登録されていません/, response.body)
  end

  test "new はスケジュール登録フォームを表示する" do
    sign_in users(:one)

    get new_user_schedule_url

    assert_response :success
    assert_select "h1", text: "スケジュール登録"
    assert_select "form[action=?]", user_schedules_path
    assert_select "input[name=?]", "user_schedule[scheduled_smoking_time]"
  end

  test "create はログインユーザーに紐づくスケジュールを作成して一覧へ戻る" do
    sign_in users(:one)

    assert_difference -> { users(:one).user_schedules.count }, 1 do
      post user_schedules_url, params: {
        user_schedule: {
          scheduled_smoking_time: "08:30",
          label: "朝の一服",
          is_active: "1",
          user_id: users(:two).id
        }
      }
    end

    assert_redirected_to user_schedules_url
    schedule = users(:one).user_schedules.order(:created_at).last
    assert_equal "朝の一服", schedule.label
    assert schedule.is_active
    assert_equal users(:one), schedule.user
  end

  test "create はバリデーションエラーなら 422 で new を再表示する" do
    sign_in users(:one)

    assert_no_difference -> { UserSchedule.count } do
      post user_schedules_url, params: {
        user_schedule: {
          scheduled_smoking_time: "",
          label: "時間なし",
          is_active: "1"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h1", text: "スケジュール登録"
    assert_select ".bg-red-50"
  end
end
