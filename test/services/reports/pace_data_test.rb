require "test_helper"

class Reports::PaceDataTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @today = Date.new(2026, 8, 8)
  end

  test "昨日までの7日分が揃うと整数の平均本数と目標との差を返す" do
    smoking_counts = [ 3, 3, 3, 3, 3, 4, 4 ]
    create_week(@user, smoking_counts: smoking_counts, targets: Array.new(7, 5))

    result = Reports::PaceData.call(@user, today: @today)

    assert result.complete?
    assert_equal 7, result.recorded_days
    assert_equal 0, result.remaining_days
    assert_equal 4, result.average_smoking_count
    assert_equal 23, result.smoking_total
    assert_equal 35, result.target_total
    assert_equal 12, result.target_difference
  end

  test "節約額はsnapshotと鬼モードを使い平均と30日ペースの最後で切り捨てる" do
    create_week(
      @user,
      smoking_counts: [ 3, 3, 3, 3, 4, 4, 6 ],
      targets: Array.new(7, 5),
      oni_mode_indexes: [ 6 ]
    )

    result = Reports::PaceData.call(@user, today: @today)

    # 通常6日分は2,500円、鬼モードで目標超過した最終日は0円。
    assert_equal 357, result.average_saved_yen
    assert_equal 10_714, result.thirty_day_saved_yen
  end

  test "30日ペースは切り捨てた1日平均へ30を掛けず正確な合計から算出する" do
    create_week(
      @user,
      smoking_counts: [ 3, 3, 3, 3, 3, 4, 4 ],
      targets: Array.new(7, 5)
    )

    result = Reports::PaceData.call(@user, today: @today)

    assert_equal 417, result.average_saved_yen
    assert_equal 12_535, result.thirty_day_saved_yen
    assert_not_equal result.average_saved_yen * 30, result.thirty_day_saved_yen
  end

  test "記録が不足している場合は残り日数を返し平均とペースを計算しない" do
    create_week(
      @user,
      smoking_counts: Array.new(6, 3),
      targets: Array.new(6, 5),
      days: 6
    )

    result = Reports::PaceData.call(@user, today: @today)

    assert_not result.complete?
    assert_equal 6, result.recorded_days
    assert_equal 1, result.remaining_days
    assert_nil result.average_smoking_count
    assert_nil result.target_difference
    assert_nil result.average_saved_yen
    assert_nil result.thirty_day_saved_yen
  end

  test "今日と期間外と他ユーザーのログを含めない" do
    create_week(
      @user,
      smoking_counts: Array.new(6, 3),
      targets: Array.new(6, 5),
      days: 6
    )
    create_log(@user, smoked_on: @today, smoking_count: 0, target: 5)
    create_log(@user, smoked_on: @today - 8.days, smoking_count: 0, target: 5)
    create_log(@other_user, smoked_on: @today - 1.day, smoking_count: 0, target: 5)

    result = Reports::PaceData.call(@user, today: @today)

    assert_not result.complete?
    assert_equal 6, result.recorded_days
    assert_equal 1, result.remaining_days
  end

  test "実績と目標の7日合計が同じ場合と超過した場合の差を符号付きで返す" do
    create_week(@user, smoking_counts: Array.new(7, 5), targets: Array.new(7, 5))

    equal_result = Reports::PaceData.call(@user, today: @today)

    assert_equal 0, equal_result.target_difference

    @user.user_smoking_logs.find_by!(smoked_on: @today - 1.day).update!(smoking_count: 7)

    exceeded_result = Reports::PaceData.call(@user, today: @today)

    assert_equal(-2, exceeded_result.target_difference)
  end

  private

  def create_week(user, smoking_counts:, targets:, days: 7, oni_mode_indexes: [])
    days.times do |index|
      create_log(
        user,
        smoked_on: @today - (days - index).days,
        smoking_count: smoking_counts[index],
        target: targets[index],
        oni_mode: oni_mode_indexes.include?(index)
      )
    end
  end

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
