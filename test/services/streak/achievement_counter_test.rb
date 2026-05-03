# frozen_string_literal: true

require "test_helper"

class Streak::AchievementCounterTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "streak_#{SecureRandom.hex(4)}@example.test",
      name: "Streak User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "昨日にログ行がなければ継続日数は0" do
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 3)

    assert_equal 0, Streak::AchievementCounter.call(@user)
  end

  test "昨日から連続して達成した日数を数える" do
    create_log(smoked_on: Time.zone.today - 3.days, smoking_count: 5)
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 4)
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 0)

    assert_equal 3, Streak::AchievementCounter.call(@user)
  end

  test "未達の日で継続日数のカウントを止める" do
    create_log(smoked_on: Time.zone.today - 4.days, smoking_count: 0)
    create_log(smoked_on: Time.zone.today - 3.days, smoking_count: 4)
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 6)
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 5)

    assert_equal 1, Streak::AchievementCounter.call(@user)
  end

  test "達成判定はログの目標本数snapshotを使う" do
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 0)
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 4, target_daily_cigarette_count_snapshot: 3)

    assert_equal 0, Streak::AchievementCounter.call(@user)
  end

  test "途中に未記録日があればそれより過去は数えない" do
    create_log(smoked_on: Time.zone.today - 4.days, smoking_count: 0)
    create_log(smoked_on: Time.zone.today - 2.days, smoking_count: 4)
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 5)

    assert_equal 2, Streak::AchievementCounter.call(@user)
  end

  test "当日の達成ログは継続日数に含めない" do
    create_log(smoked_on: Time.zone.today, smoking_count: 0)

    assert_equal 0, Streak::AchievementCounter.call(@user)
  end

  test "指定した today を基準に継続日数を算出する" do
    base_day = Date.new(2026, 5, 1)
    create_log(smoked_on: base_day - 3.days, smoking_count: 0)
    create_log(smoked_on: base_day - 2.days, smoking_count: 4)
    create_log(smoked_on: base_day - 1.day, smoking_count: 5)
    create_log(smoked_on: base_day, smoking_count: 0)

    assert_equal 3, Streak::AchievementCounter.call(@user, today: base_day)
  end

  private

  def create_log(smoked_on:, smoking_count:, target_daily_cigarette_count_snapshot: 5)
    @user.user_smoking_logs.create!(
      smoked_on: smoked_on,
      smoking_count: smoking_count,
      target_daily_cigarette_count_snapshot: target_daily_cigarette_count_snapshot,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    )
  end
end
