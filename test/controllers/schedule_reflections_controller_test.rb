# frozen_string_literal: true

require "test_helper"

class ScheduleReflectionsControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    post schedule_reflection_url

    assert_redirected_to new_user_session_url
  end

  test "reflects active schedules and redirects to dashboard" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.where(smoked_on: Time.zone.today).destroy_all
    user.user_schedules.destroy_all
    user.user_schedules.create!(scheduled_smoking_time: "08:00", label: "朝", is_active: true)
    user.user_schedules.create!(scheduled_smoking_time: "12:00", label: "昼", is_active: false)

    assert_difference -> { UserScheduleReflection.count }, 1 do
      post schedule_reflection_url
    end

    assert_redirected_to dashboard_url
    follow_redirect!
    assert_match(/スケジュールを1件反映しました。/, response.body)
    assert_equal 1, user.user_smoking_logs.find_by!(smoked_on: Time.zone.today).smoking_count
  end

  test "second reflection request does not increase today count" do
    user = users(:one)
    sign_in user
    user.user_smoking_logs.where(smoked_on: Time.zone.today).destroy_all
    user.user_schedules.destroy_all
    user.user_schedules.create!(scheduled_smoking_time: "08:00", label: "朝", is_active: true)

    post schedule_reflection_url

    assert_no_difference -> { UserScheduleReflection.count } do
      post schedule_reflection_url
    end

    assert_redirected_to dashboard_url
    follow_redirect!
    assert_match(/本日分の未反映スケジュールはありません。/, response.body)
    assert_equal 1, user.user_smoking_logs.find_by!(smoked_on: Time.zone.today).smoking_count
  end
end
