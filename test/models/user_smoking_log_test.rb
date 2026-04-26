# frozen_string_literal: true

require "test_helper"

class UserSmokingLogTest < ActiveSupport::TestCase
  SNAPSHOTS = {
    target_daily_cigarette_count_snapshot: 5,
    baseline_daily_cigarette_count_snapshot: 20,
    pack_price_snapshot: 500,
    cigarettes_per_pack_snapshot: 20,
    is_oni_mode_snapshot: false
  }.freeze

  def setup
    @user = User.create!(
      email: "smoking_log_#{SecureRandom.hex(4)}@example.test",
      name: "Log User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def build_log(smoked_on: Date.current, smoking_count: 0, **extra)
    @user.user_smoking_logs.build(
      { smoked_on: smoked_on, smoking_count: smoking_count, **UserSmokingLogTest::SNAPSHOTS, **extra }
    )
  end

  test "saves with valid attributes" do
    log = build_log
    assert log.save
    assert log.persisted?
  end

  test "rejects duplicate user_id and smoked_on" do
    build_log.save!
    other = build_log
    assert_not other.save
    assert other.errors.key?(:smoked_on)
  end

  test "rejects negative smoking_count" do
    log = build_log(smoking_count: -1)
    assert_not log.save
    assert log.errors.key?(:smoking_count)
  end

  test "rejects non-integer smoking_count" do
    log = build_log
    log.smoking_count = 1.5
    assert_not log.save
  end

  test "belongs_to user" do
    log = build_log
    log.save!
    assert_equal @user, log.user
  end

  test "user destroy destroys dependent logs" do
    build_log.save!
    assert_difference -> { UserSmokingLog.count }, -1 do
      @user.destroy
    end
  end
end
