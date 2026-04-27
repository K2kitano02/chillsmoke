# frozen_string_literal: true

require "test_helper"

class SmokingLog::TodayTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "today_sl_#{SecureRandom.hex(4)}@example.test",
      name: "Today Log",
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

  test "for_display returns persisted log when row exists" do
    log = @user.user_smoking_logs.create!(
      smoked_on: Time.zone.today,
      smoking_count: 3,
      **snapshot_attrs(7, 25, 600, 20, true)
    )

    got = SmokingLog::Today.for_display(@user)
    assert_equal log.id, got.id
    assert got.persisted?
    assert_equal 3, got.smoking_count
  end

  test "for_display returns virtual log when no row for today without persisting" do
    assert_no_difference -> { UserSmokingLog.count } do
      got = SmokingLog::Today.for_display(@user)
      assert_not got.persisted?
      assert_equal Time.zone.today, got.smoked_on
      assert_equal 0, got.smoking_count
      assert_equal 5, got.target_daily_cigarette_count_snapshot
      assert_equal 20, got.baseline_daily_cigarette_count_snapshot
      assert_equal 500, got.pack_price_snapshot
      assert_equal 20, got.cigarettes_per_pack_snapshot
      assert_equal false, got.is_oni_mode_snapshot
    end
  end

  test "for_display reflects current user_setting on virtual log" do
    @user.user_setting.update!(target_daily_cigarette_count: 8, is_oni_mode: true)

    got = SmokingLog::Today.for_display(@user)
    assert_not got.persisted?
    assert_equal 8, got.target_daily_cigarette_count_snapshot
    assert_equal true, got.is_oni_mode_snapshot
  end

  test "find_or_create_persisted! creates row with snapshots from user_setting" do
    assert_difference -> { UserSmokingLog.count }, 1 do
      log = SmokingLog::Today.find_or_create_persisted!(@user)
      assert log.persisted?
      assert_equal Time.zone.today, log.smoked_on
      assert_equal 0, log.smoking_count
      assert_equal 5, log.target_daily_cigarette_count_snapshot
      assert_equal 20, log.baseline_daily_cigarette_count_snapshot
      assert_equal 500, log.pack_price_snapshot
      assert_equal 20, log.cigarettes_per_pack_snapshot
      assert_equal false, log.is_oni_mode_snapshot
    end
  end

  test "find_or_create_persisted! returns existing row without changing snapshots" do
    log = @user.user_smoking_logs.create!(
      smoked_on: Time.zone.today,
      smoking_count: 2,
      **snapshot_attrs(5, 20, 500, 20, false)
    )
    @user.user_setting.update!(target_daily_cigarette_count: 8)

    assert_no_difference -> { UserSmokingLog.count } do
      again = SmokingLog::Today.find_or_create_persisted!(@user)
      assert_equal log.id, again.id
      assert_equal 2, again.smoking_count
      assert_equal 5, again.target_daily_cigarette_count_snapshot
    end
  end

  test "repeated for_display does not create rows" do
    3.times { assert_not SmokingLog::Today.for_display(@user).persisted? }
    assert_equal 0, @user.user_smoking_logs.count
  end

  private

  def snapshot_attrs(target, baseline, pack, per_pack, oni)
    {
      target_daily_cigarette_count_snapshot: target,
      baseline_daily_cigarette_count_snapshot: baseline,
      pack_price_snapshot: pack,
      cigarettes_per_pack_snapshot: per_pack,
      is_oni_mode_snapshot: oni
    }
  end
end
