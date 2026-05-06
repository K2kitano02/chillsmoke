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
  end

  test "belongs_to user" do
    assert_equal users(:one), user_schedules(:morning).user
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
end
