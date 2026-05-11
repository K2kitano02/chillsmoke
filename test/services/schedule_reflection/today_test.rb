# frozen_string_literal: true

require "test_helper"

class ScheduleReflection::TodayTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "schedule_reflection_#{SecureRandom.hex(4)}@example.test",
      name: "Schedule Reflection",
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
  end

  test "creates today log with snapshots and adds one count per active schedule" do
    active_one = create_schedule("08:00")
    active_two = create_schedule("12:00")
    create_schedule("20:00", is_active: false)

    assert_difference -> { UserSmokingLog.count }, 1 do
      assert_difference -> { UserScheduleReflection.count }, 2 do
        result = ScheduleReflection::Today.call(@user)

        assert_equal 2, result.reflected_count
      end
    end

    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 2, log.smoking_count
    assert_equal 5, log.target_daily_cigarette_count_snapshot
    assert_equal 20, log.baseline_daily_cigarette_count_snapshot
    assert_equal 500, log.pack_price_snapshot
    assert_equal 20, log.cigarettes_per_pack_snapshot
    assert_equal false, log.is_oni_mode_snapshot
    assert_reflected active_one
    assert_reflected active_two
  end

  test "adds to existing today log without changing snapshots" do
    create_schedule("08:00")
    existing = @user.user_smoking_logs.create!(
      smoked_on: Time.zone.today,
      smoking_count: 3,
      target_daily_cigarette_count_snapshot: 7,
      baseline_daily_cigarette_count_snapshot: 25,
      pack_price_snapshot: 600,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: true
    )
    @user.user_setting.update!(target_daily_cigarette_count: 4)

    result = ScheduleReflection::Today.call(@user)

    assert_equal 1, result.reflected_count
    existing.reload
    assert_equal 4, existing.smoking_count
    assert_equal 7, existing.target_daily_cigarette_count_snapshot
    assert_equal true, existing.is_oni_mode_snapshot
  end

  test "is idempotent for already reflected schedules" do
    schedule = create_schedule("08:00")
    ScheduleReflection::Today.call(@user)

    assert_no_difference -> { UserScheduleReflection.count } do
      result = ScheduleReflection::Today.call(@user)

      assert_equal 0, result.reflected_count
    end

    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 1, log.smoking_count
    assert_reflected schedule
  end

  test "reflects only unreflected active schedules on subsequent calls" do
    reflected = create_schedule("08:00")
    ScheduleReflection::Today.call(@user)
    new_schedule = create_schedule("12:00")

    result = ScheduleReflection::Today.call(@user)

    assert_equal 1, result.reflected_count
    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 2, log.smoking_count
    assert_reflected reflected
    assert_reflected new_schedule
  end

  test "does not reflect inactive schedules" do
    create_schedule("08:00", is_active: false)

    result = ScheduleReflection::Today.call(@user)

    assert_equal 0, result.reflected_count
    log = @user.user_smoking_logs.find_by!(smoked_on: Time.zone.today)
    assert_equal 0, log.smoking_count
    assert_equal 0, UserScheduleReflection.count
  end

  private

  def create_schedule(time, is_active: true)
    @user.user_schedules.create!(
      scheduled_smoking_time: time,
      label: time,
      is_active: is_active
    )
  end

  def assert_reflected(schedule)
    assert schedule.user_schedule_reflections.exists?(reflected_on: Time.zone.today)
  end
end
