# frozen_string_literal: true

require "test_helper"

class UserSettingTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "user_setting_isolated_#{SecureRandom.hex(4)}@example.test",
      name: "Isolated",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "saves with valid required attributes" do
    s = @user.build_user_setting(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20
    )
    assert s.save
  end

  test "rejects duplicate user_id" do
    @user.create_user_setting!(
      target_daily_cigarette_count: 5,
      baseline_daily_cigarette_count: 20,
      pack_price: 500,
      cigarettes_per_pack: 20
    )
    other = UserSetting.new(
      user: @user,
      target_daily_cigarette_count: 1,
      baseline_daily_cigarette_count: 5,
      pack_price: 100,
      cigarettes_per_pack: 20
    )
    assert_not other.save
    assert other.errors.key?(:user_id)
  end

  test "rejects when baseline is less than target" do
    s = @user.build_user_setting(
      target_daily_cigarette_count: 20,
      baseline_daily_cigarette_count: 5,
      pack_price: 500,
      cigarettes_per_pack: 20
    )
    assert_not s.save
    assert s.errors.key?(:baseline_daily_cigarette_count)
  end

  test "rejects non-positive integers for counts and price" do
    s = @user.build_user_setting(
      target_daily_cigarette_count: 0,
      baseline_daily_cigarette_count: 0,
      pack_price: 0,
      cigarettes_per_pack: 0
    )
    assert_not s.save
  end

  test "belongs_to user" do
    s = user_settings(:one)
    assert_equal users(:one), s.user
  end

  test "fixture has required columns and satisfies baseline gte target" do
    s = user_settings(:one)
    assert s.target_daily_cigarette_count.positive?
    assert s.baseline_daily_cigarette_count >= s.target_daily_cigarette_count
    assert s.pack_price.positive?
    assert s.cigarettes_per_pack.positive?
  end
end
