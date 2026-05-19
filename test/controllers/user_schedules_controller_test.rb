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

  test "一覧は画面表示時刻の早い順で表示する" do
    sign_in users(:one)
    users(:one).user_schedules.create!(scheduled_smoking_time: "21:30", label: "夜", is_active: true)

    get user_schedules_url

    assert_response :success
    assert_operator response.body.index("08:00"), :<, response.body.index("21:30")
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

  test "一覧から編集画面へ進める" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    get user_schedules_url

    assert_response :success
    assert_select "a[href=?]", edit_user_schedule_path(schedule), text: "編集"
  end

  test "edit はログインユーザーのスケジュール編集フォームを表示する" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    get edit_user_schedule_url(schedule)

    assert_response :success
    assert_select "h1", text: "スケジュール編集"
    assert_select "form[action=?]", user_schedule_path(schedule)
    assert_select "input[name=?]", "user_schedule[scheduled_smoking_time]"
  end

  test "edit は他ユーザーのスケジュールなら 404 を返す" do
    sign_in users(:one)

    get edit_user_schedule_url(user_schedules(:inactive))

    assert_response :not_found
  end

  test "update はログインユーザーのスケジュールを更新して一覧へ戻る" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    patch user_schedule_url(schedule), params: {
      user_schedule: {
        scheduled_smoking_time: "09:15",
        label: "午前休憩",
        is_active: "0",
        user_id: users(:two).id
      }
    }

    assert_redirected_to user_schedules_url
    schedule.reload
    assert_equal "午前休憩", schedule.label
    assert_equal 555, schedule.scheduled_smoking_minutes
    assert_not schedule.is_active
    assert_equal users(:one), schedule.user
  end

  test "update は他ユーザーのスケジュールなら 404 を返して更新しない" do
    sign_in users(:one)
    schedule = user_schedules(:inactive)

    patch user_schedule_url(schedule), params: {
      user_schedule: {
        scheduled_smoking_time: "10:00",
        label: "変更不可",
        is_active: "1"
      }
    }

    assert_response :not_found
    schedule.reload
    assert_equal "夜", schedule.label
    assert_not schedule.is_active
  end

  test "update はバリデーションエラーなら 422 で edit を再表示する" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    patch user_schedule_url(schedule), params: {
      user_schedule: {
        scheduled_smoking_time: "",
        label: "時間なし",
        is_active: "1"
      }
    }

    assert_response :unprocessable_entity
    assert_select "h1", text: "スケジュール編集"
    assert_select ".bg-red-50"
  end

  test "一覧から削除できる" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    get user_schedules_url

    assert_response :success
    assert_select "form[action=?]", user_schedule_path(schedule) do
      assert_select "button", text: "削除"
    end
  end

  test "destroy はログインユーザーのスケジュールを削除して一覧へ戻る" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    assert_difference -> { users(:one).user_schedules.count }, -1 do
      delete user_schedule_url(schedule)
    end

    assert_redirected_to user_schedules_url
    assert_nil UserSchedule.find_by(id: schedule.id)
  end

  test "destroy は他ユーザーのスケジュールなら 404 を返して削除しない" do
    sign_in users(:one)
    schedule = user_schedules(:inactive)

    assert_no_difference -> { UserSchedule.count } do
      delete user_schedule_url(schedule)
    end

    assert_response :not_found
    assert UserSchedule.exists?(schedule.id)
  end

  test "一覧から有効状態を切り替えられる" do
    sign_in users(:one)
    schedule = user_schedules(:morning)

    get user_schedules_url

    assert_response :success
    assert_select "form[action=?]", toggle_user_schedule_path(schedule) do
      assert_select "button", text: "停止する"
    end
  end

  test "toggle は有効なスケジュールを停止して一覧へ戻る" do
    sign_in users(:one)
    schedule = user_schedules(:morning)
    assert schedule.is_active

    patch toggle_user_schedule_url(schedule)

    assert_redirected_to user_schedules_url
    assert_not schedule.reload.is_active
  end

  test "toggle は停止中のスケジュールを有効にして一覧へ戻る" do
    sign_in users(:two)
    schedule = user_schedules(:inactive)
    assert_not schedule.is_active

    patch toggle_user_schedule_url(schedule)

    assert_redirected_to user_schedules_url
    assert schedule.reload.is_active
  end

  test "toggle は他ユーザーのスケジュールなら 404 を返して切り替えない" do
    sign_in users(:one)
    schedule = user_schedules(:inactive)

    patch toggle_user_schedule_url(schedule)

    assert_response :not_found
    assert_not schedule.reload.is_active
  end
end
