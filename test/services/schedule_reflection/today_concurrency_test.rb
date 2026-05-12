# frozen_string_literal: true

require "test_helper"

class ScheduleReflection::TodayConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @user = User.create!(
      email: "schedule_reflection_concurrent_#{SecureRandom.hex(4)}@example.test",
      name: "Schedule Reflection Concurrent",
      password: "password123",
      password_confirmation: "password123"
    )
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20,
      is_oni_mode: false
    )
    5.times do |i|
      @user.user_schedules.create!(
        scheduled_smoking_time: format("%02d:00", i + 8),
        label: "schedule #{i}",
        is_active: true
      )
    end
  end

  teardown do
    @user&.destroy
  end

  test "parallel reflection does not duplicate counts or reflections" do
    threads = 8.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ScheduleReflection::Today.call(@user)
        end
      end
    end
    threads.each(&:join)

    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 5, log.smoking_count
    assert_equal 5, UserScheduleReflection.joins(:user_schedule).where(user_schedules: { user_id: @user.id }).count
  end
end
