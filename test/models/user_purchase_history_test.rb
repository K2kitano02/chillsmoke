# frozen_string_literal: true

require "test_helper"

class UserPurchaseHistoryTest < ActiveSupport::TestCase
  test "saves with valid attributes" do
    wishlist = users(:one).user_wishlists.create!(name: "イヤホン", price: 15_000)
    purchase_history = wishlist.build_user_purchase_history(
      amount: 15_000,
      purchased_at: Time.current
    )

    assert purchase_history.save
  end

  test "belongs to user_wishlist" do
    assert_equal user_wishlists(:purchased_bag), user_purchase_histories(:bag_purchase).user_wishlist
  end

  test "rejects duplicate purchase history for same wishlist" do
    purchase_history = UserPurchaseHistory.new(
      user_wishlist: user_wishlists(:purchased_bag),
      amount: 12_000,
      purchased_at: Time.current
    )

    assert_not purchase_history.save
    assert purchase_history.errors.key?(:user_wishlist_id)
  end

  test "database prevents duplicate purchase history for same wishlist" do
    assert_raises ActiveRecord::RecordNotUnique do
      UserPurchaseHistory.insert_all!(
        [
          {
            user_wishlist_id: user_wishlists(:purchased_bag).id,
            amount: 12_000,
            purchased_at: Time.current,
            created_at: Time.current,
            updated_at: Time.current
          }
        ]
      )
    end
  end

  test "rejects non positive amount" do
    wishlist = users(:one).user_wishlists.create!(name: "小物", price: 1000)
    purchase_history = wishlist.build_user_purchase_history(amount: 0, purchased_at: Time.current)

    assert_not purchase_history.save
    assert purchase_history.errors.key?(:amount)
  end

  test "rejects blank purchased_at" do
    wishlist = users(:one).user_wishlists.create!(name: "本", price: 1200)
    purchase_history = wishlist.build_user_purchase_history(amount: 1200, purchased_at: nil)

    assert_not purchase_history.save
    assert purchase_history.errors.key?(:purchased_at)
  end
end
