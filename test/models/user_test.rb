# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has_one user_setting" do
    u = users(:one)
    assert_equal user_settings(:one), u.user_setting
  end

  test "destroying user destroys dependent user_setting" do
    u = User.create!(
      email: "user_destroy_setting_#{SecureRandom.hex(4)}@example.test",
      name: "Zap",
      password: "password123",
      password_confirmation: "password123"
    )
    u.create_user_setting!(
      target_daily_cigarette_count: 3,
      baseline_daily_cigarette_count: 10,
      pack_price: 400,
      cigarettes_per_pack: 20
    )
    assert_difference "UserSetting.count", -1 do
      u.destroy
    end
  end
end
