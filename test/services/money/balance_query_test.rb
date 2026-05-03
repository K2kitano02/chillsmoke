# frozen_string_literal: true

require "test_helper"

class Money::BalanceQueryTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "balance_#{SecureRandom.hex(4)}@example.test",
      name: "Balance User",
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

  test "purchase が未実装なら使用額0として残高を返す" do
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 10)

    result = Money::BalanceQuery.call(@user)

    assert_equal 250, result.cumulative_saved_yen
    assert_equal 0, result.cumulative_spent_yen
    assert_equal 250, result.usable_yen
  end

  test "残高は今日の節約見込みを含めない" do
    create_log(smoked_on: Time.zone.today, smoking_count: 0)

    result = Money::BalanceQuery.call(@user)

    assert_equal 0, result.cumulative_saved_yen
    assert_equal 0, result.usable_yen
  end

  test "purchase 関連が実装されたら使用額を差し引く" do
    create_log(smoked_on: Time.zone.today - 1.day, smoking_count: 4)
    attach_purchase_histories_sum(120)

    result = Money::BalanceQuery.call(@user)

    assert_equal 400, result.cumulative_saved_yen
    assert_equal 120, result.cumulative_spent_yen
    assert_equal 280, result.usable_yen
  end

  test "指定した today を基準に残高を算出する" do
    base_day = Date.new(2026, 5, 1)
    create_log(smoked_on: base_day - 1.day, smoking_count: 10)
    create_log(smoked_on: base_day, smoking_count: 0)

    result = Money::BalanceQuery.call(@user, today: base_day)

    assert_equal 250, result.cumulative_saved_yen
    assert_equal 250, result.usable_yen
  end

  private

  def create_log(smoked_on:, smoking_count:)
    @user.user_smoking_logs.create!(
      smoked_on: smoked_on,
      smoking_count: smoking_count,
      target_daily_cigarette_count_snapshot: 5,
      baseline_daily_cigarette_count_snapshot: 20,
      pack_price_snapshot: 500,
      cigarettes_per_pack_snapshot: 20,
      is_oni_mode_snapshot: false
    )
  end

  def attach_purchase_histories_sum(amount)
    purchase_histories = Struct.new(:amount) do
      def sum(column_name)
        raise ArgumentError, "unexpected column" unless column_name == :amount

        amount
      end
    end
    histories = purchase_histories.new(amount)

    @user.define_singleton_method(:user_purchase_histories) { histories }
  end
end
