# frozen_string_literal: true

require "test_helper"

class UserScheduleTest < ActiveSupport::TestCase
  test "saves with valid attributes" do
    schedule = users(:one).user_schedules.build(
      scheduled_smoking_time: "12:30",
      label: "昼休み",
      is_active: true
    )

    assert schedule.save
    assert schedule.persisted?
    assert_equal 750, schedule.scheduled_smoking_minutes
    assert_equal "12:30", schedule.scheduled_smoking_time
  end

  test "belongs_to user" do
    assert_equal users(:one), user_schedules(:morning).user
  end

  test "destroys dependent reflections" do
    schedule = user_schedules(:morning)
    schedule.user_schedule_reflections.create!(reflected_on: Time.zone.today)

    assert_difference -> { UserScheduleReflection.count }, -1 do
      schedule.destroy!
    end
  end

  test "rejects blank scheduled_smoking_time" do
    schedule = users(:one).user_schedules.build(
      label: "時間なし",
      is_active: true
    )

    assert_not schedule.save
    assert schedule.errors.key?(:scheduled_smoking_time)
  end

  test "is_active defaults to true" do
    schedule = users(:one).user_schedules.create!(
      scheduled_smoking_time: "15:00"
    )

    assert schedule.is_active
  end

  test "rejects invalid scheduled_smoking_time format" do
    schedule = users(:one).user_schedules.build(
      scheduled_smoking_time: "25:99",
      label: "不正な時刻",
      is_active: true
    )

    assert_not schedule.save
    assert schedule.errors.key?(:scheduled_smoking_time)
  end
end
