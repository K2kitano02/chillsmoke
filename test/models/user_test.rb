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

  test "has_many user_schedules" do
    u = users(:one)

    assert_includes u.user_schedules, user_schedules(:morning)
  end

  test "destroying user destroys dependent user_schedules" do
    u = User.create!(
      email: "user_destroy_schedule_#{SecureRandom.hex(4)}@example.test",
      name: "Schedule Owner",
      password: "password123",
      password_confirmation: "password123"
    )
    u.user_schedules.create!(scheduled_smoking_time: "08:00", label: "朝")

    assert_difference "UserSchedule.count", -1 do
      u.destroy
    end
  end

  test "has_many user_wishlists" do
    u = users(:one)

    assert_includes u.user_wishlists, user_wishlists(:watch)
  end

  test "has_many user_purchase_histories through user_wishlists" do
    u = users(:two)

    assert_includes u.user_purchase_histories, user_purchase_histories(:bag_purchase)
  end

  test "destroying user destroys dependent user_wishlists" do
    u = User.create!(
      email: "user_destroy_wishlist_#{SecureRandom.hex(4)}@example.test",
      name: "Wishlist Owner",
      password: "password123",
      password_confirmation: "password123"
    )
    u.user_wishlists.create!(name: "ご褒美", price: 5000)

    assert_difference "UserWishlist.count", -1 do
      u.destroy
    end
  end
end
