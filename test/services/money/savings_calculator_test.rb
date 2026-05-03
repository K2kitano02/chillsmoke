# frozen_string_literal: true

require "test_helper"

class Money::SavingsCalculatorTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "savings_#{SecureRandom.hex(4)}@example.test",
      name: "Savings User",
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

  test "累計節約は昨日までのログだけを合算し当日を含めない" do
    yesterday = Time.zone.today - 1.day
    today = Time.zone.today
    create_log(smoked_on: yesterday, smoking_count: 10)
    create_log(smoked_on: today, smoking_count: 0)

    summary = Money::SavingsCalculator.call(@user)

    assert_equal 250, summary.cumulative_saved_yen
  end

  test "累計節約は複数の過去ログを snapshot ベースで合算する" do
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 10)
    create_log(
      smoked_on: Time.zone.today - 1.day,
      smoking_count: 4,
      baseline_daily_cigarette_count_snapshot: 10,
      pack_price_snapshot: 600,
      cigarettes_per_pack_snapshot: 12
    )

    summary = Money::SavingsCalculator.call(@user)

    assert_equal 550, summary.cumulative_saved_yen
  end

  test "今日の節約見込みは当日ログがある場合そのログから算出する" do
    create_log(smoked_on: Time.zone.today, smoking_count: 8)

    summary = Money::SavingsCalculator.call(@user)

    assert_equal 300, summary.today_estimated_saved_yen
  end

  test "今日の節約見込みは当日ログがない場合仮想0本から算出しログを作らない" do
    assert_no_difference -> { UserSmokingLog.count } do
      summary = Money::SavingsCalculator.call(@user)

      assert_equal 500, summary.today_estimated_saved_yen
    end
  end

  test "今日の節約見込みは累計節約へ混入しない" do
    summary = Money::SavingsCalculator.call(@user)

    assert_equal 0, summary.cumulative_saved_yen
    assert_equal 500, summary.today_estimated_saved_yen
  end

  test "指定した today を基準に累計と見込みを算出する" do
    base_day = Date.new(2026, 5, 1)
    create_log(smoked_on: base_day - 1.day, smoking_count: 10)
    create_log(smoked_on: base_day, smoking_count: 4)
    create_log(smoked_on: base_day + 1.day, smoking_count: 0)

    summary = Money::SavingsCalculator.call(@user, today: base_day)

    assert_equal 250, summary.cumulative_saved_yen
    assert_equal 400, summary.today_estimated_saved_yen
  end

  private

  def create_log(smoked_on:, smoking_count:, **snapshot_overrides)
    @user.user_smoking_logs.create!(
      {
        smoked_on: smoked_on,
        smoking_count: smoking_count,
        target_daily_cigarette_count_snapshot: 5,
        baseline_daily_cigarette_count_snapshot: 20,
        pack_price_snapshot: 500,
        cigarettes_per_pack_snapshot: 20,
        is_oni_mode_snapshot: false
      }.merge(snapshot_overrides)
    )
  end
end
