require "test_helper"

class Reports::TrendDataTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @today = Date.new(2026, 8, 7)
  end

  test "直近30日の日付を古い順に並べて30日より前と他ユーザーのログを含めない" do
    first_day = @today - 29.days
    create_log(@user, smoked_on: first_day, smoking_count: 3, target: 6)
    create_log(@user, smoked_on: @today - 30.days, smoking_count: 9, target: 9)
    create_log(@other_user, smoked_on: @today - 1.day, smoking_count: 12, target: 12)

    result = Reports::TrendData.call(@user, today: @today)

    assert_equal 30, result.dates.length
    assert_equal first_day, result.dates.first
    assert_equal @today, result.dates.last
    assert_equal 3, result.smoking_counts.first
    assert_equal 6, result.target_counts.first
    assert_nil result.smoking_counts[-2]
    assert_nil result.target_counts[-2]
  end

  test "未記録日はnilで0本記録日は0として返しsnapshot目標を使う" do
    recorded_day = @today - 2.days
    create_log(@user, smoked_on: recorded_day, smoking_count: 0, target: 4)

    result = Reports::TrendData.call(@user, today: @today)
    recorded_index = result.dates.index(recorded_day)
    missing_index = result.dates.index(@today - 1.day)

    assert_equal 0, result.smoking_counts[recorded_index]
    assert_equal 4, result.target_counts[recorded_index]
    assert_nil result.smoking_counts[missing_index]
    assert_nil result.target_counts[missing_index]
  end

  test "昨日までの日別節約額へsnapshotと鬼モードを反映し今日分は含めない" do
    regular_day = @today - 2.days
    oni_day = @today - 1.day
    create_log(@user, smoked_on: regular_day, smoking_count: 10, target: 5)
    create_log(@user, smoked_on: oni_day, smoking_count: 6, target: 5, oni_mode: true)
    create_log(@user, smoked_on: @today, smoking_count: 0, target: 5)

    result = Reports::TrendData.call(@user, today: @today)

    assert_equal 250, result.saved_yen[result.dates.index(regular_day)]
    assert_equal 0, result.saved_yen[result.dates.index(oni_day)]
    assert_nil result.saved_yen[result.dates.index(@today)]
    assert_equal 250, result.confirmed_saved_yen
    assert_equal 1, result.achieved_count
    assert result.recorded?
    assert result.confirmed_recorded?
  end

  test "直近7日は日付ごとの実績とsnapshot目標を未記録も含めて返す" do
    recorded_day = @today - 1.day
    create_log(@user, smoked_on: recorded_day, smoking_count: 3, target: 4)

    result = Reports::TrendData.call(@user, today: @today)

    assert_equal @today - 6.days, result.recent_smoking_days.first[:date]
    assert_nil result.recent_smoking_days.first[:smoking_count]
    assert_equal recorded_day, result.recent_smoking_days[-2][:date]
    assert_equal 3, result.recent_smoking_days[-2][:smoking_count]
    assert_equal 4, result.recent_smoking_days[-2][:target_count]
    assert_nil result.recent_smoking_days.last[:smoking_count]
  end

  test "対象期間に記録がなければrecorded?はfalseを返す" do
    create_log(@user, smoked_on: @today - 30.days, smoking_count: 1, target: 5)

    result = Reports::TrendData.call(@user, today: @today)

    assert_not result.recorded?
    assert_not result.confirmed_recorded?
  end

  test "今日だけ記録がある場合は確定済みの日別節約額なしと判定する" do
    create_log(@user, smoked_on: @today, smoking_count: 2, target: 5)

    result = Reports::TrendData.call(@user, today: @today)

    assert result.recorded?
    assert_not result.confirmed_recorded?
  end

  private

  def create_log(user, smoked_on:, smoking_count:, target:, oni_mode: false)
    user.user_smoking_logs.create!(
      smoked_on: smoked_on,
      smoking_count: smoking_count,
      target_daily_cigarette_count_snapshot: target,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: oni_mode
    )
  end
end
