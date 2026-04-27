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

  test "rejects blank smoking_count" do
    log = build_log
    log.smoking_count = nil
    assert_not log.save
    assert log.errors.key?(:smoking_count)
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

  test "find_or_create_for_user_by_date! creates log with snapshots from user_setting" do
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20,
      is_oni_mode: false
    )
    day = Date.current

    assert_difference -> { UserSmokingLog.count }, 1 do
      log = UserSmokingLog.find_or_create_for_user_by_date!(@user, smoked_on: day)
      assert log.persisted?
      assert_equal day, log.smoked_on
      assert_equal 5, log.target_daily_cigarette_count_snapshot
      assert_equal 500, log.pack_price_snapshot
    end
  end

  test "find_or_create_for_user_by_date! returns existing without changing snapshot" do
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20,
      is_oni_mode: false
    )
    day = Date.current
    first = UserSmokingLog.find_or_create_for_user_by_date!(@user, smoked_on: day)
    @user.user_setting.update!(target_daily_cigarette_count: 8)

    assert_no_difference -> { UserSmokingLog.count } do
      second = UserSmokingLog.find_or_create_for_user_by_date!(@user, smoked_on: day)
      assert_equal first.id, second.id
      assert_equal 5, second.target_daily_cigarette_count_snapshot
    end
  end

  test "create_persisted_for_user_by_date! re-fetches on smoked_on uniqueness after concurrent insert" do
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20,
      is_oni_mode: false
    )
    day = Date.current
    first = @user.user_smoking_logs.create!(
      smoked_on: day,
      smoking_count: 0,
      **UserSmokingLogTest::SNAPSHOTS
    )

    assert_no_difference -> { UserSmokingLog.count } do
      got = UserSmokingLog.send(:create_persisted_for_user_by_date!, @user, day)
      assert_equal first.id, got.id
    end
  end
end
