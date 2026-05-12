# frozen_string_literal: true

require "test_helper"

class UserWishlistTest < ActiveSupport::TestCase
  test "saves with valid attributes" do
    wishlist = users(:one).user_wishlists.build(
      name: "イヤホン",
      price: 15_000,
      memo: "通勤用"
    )

    assert wishlist.save
    assert_not wishlist.is_purchased
  end

  test "belongs to user" do
    assert_equal users(:one), user_wishlists(:watch).user
  end

  test "rejects blank name" do
    wishlist = users(:one).user_wishlists.build(name: "", price: 1000)

    assert_not wishlist.save
    assert wishlist.errors.key?(:name)
  end

  test "rejects non positive price" do
    wishlist = users(:one).user_wishlists.build(name: "無料サンプル", price: 0)

    assert_not wishlist.save
    assert wishlist.errors.key?(:price)
  end

  test "rejects non integer price" do
    wishlist = users(:one).user_wishlists.build(name: "小物", price: 100.5)

    assert_not wishlist.save
    assert wishlist.errors.key?(:price)
  end

  test "is_purchased defaults to false" do
    wishlist = users(:one).user_wishlists.create!(name: "本", price: 1200)

    assert_not wishlist.is_purchased
  end

  test "does not have image column in MVP" do
    assert_not_includes UserWishlist.column_names, "image"
  end
end
