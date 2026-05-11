# frozen_string_literal: true

require "test_helper"

class UserScheduleReflectionTest < ActiveSupport::TestCase
  test "belongs to user_schedule" do
    reflection = user_schedules(:morning).user_schedule_reflections.create!(reflected_on: Time.zone.today)

    assert_equal user_schedules(:morning), reflection.user_schedule
  end

  test "requires reflected_on" do
    reflection = user_schedules(:morning).user_schedule_reflections.build(reflected_on: nil)

    assert_not reflection.valid?
    assert reflection.errors.of_kind?(:reflected_on, :blank)
  end

  test "requires unique reflected_on per schedule" do
    schedule = user_schedules(:morning)
    schedule.user_schedule_reflections.create!(reflected_on: Time.zone.today)
    duplicate = schedule.user_schedule_reflections.build(reflected_on: Time.zone.today)

    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:reflected_on, :taken)
  end
end
