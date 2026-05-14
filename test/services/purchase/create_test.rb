# frozen_string_literal: true

require "test_helper"

class Purchase::CreateTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "creates purchase history through wishlist and marks wishlist purchased" do
    wishlist = @user.user_wishlists.create!(name: "イヤホン", price: 250)
    create_log(user: @user, smoking_count: 10)

    assert_difference -> { UserPurchaseHistory.count }, 1 do
      Purchase::Create.call(user: @user, wishlist: wishlist)
    end

    wishlist.reload
    assert wishlist.is_purchased
    assert_equal 250, wishlist.user_purchase_history.amount
    assert_equal wishlist, wishlist.user_purchase_history.user_wishlist
    assert_equal 0, Money::BalanceQuery.call(@user).usable_yen
  end

  test "does not purchase when usable yen is insufficient" do
    wishlist = @user.user_wishlists.create!(name: "高額品", price: 30_000)
    create_log(user: @user, smoking_count: 10)

    assert_no_difference -> { UserPurchaseHistory.count } do
      assert_raises Purchase::Create::InsufficientBalance do
        Purchase::Create.call(user: @user, wishlist: wishlist)
      end
    end

    assert_not wishlist.reload.is_purchased
  end

  test "does not purchase already purchased wishlist" do
    wishlist = user_wishlists(:purchased_bag)
    create_log(
      user: wishlist.user,
      smoking_count: 0,
      pack_price_snapshot: 30_000
    )

    assert_no_difference -> { UserPurchaseHistory.count } do
      assert_raises Purchase::Create::AlreadyPurchased do
        Purchase::Create.call(user: wishlist.user, wishlist: wishlist)
      end
    end
  end

  test "does not create duplicate history even if purchased flag is stale" do
    wishlist = user_wishlists(:purchased_bag)
    wishlist.update!(is_purchased: false)
    create_log(
      user: wishlist.user,
      smoking_count: 0,
      pack_price_snapshot: 30_000
    )

    assert_no_difference -> { UserPurchaseHistory.count } do
      assert_raises Purchase::Create::AlreadyPurchased do
        Purchase::Create.call(user: wishlist.user, wishlist: wishlist)
      end
    end

    assert_equal user_purchase_histories(:bag_purchase), wishlist.reload.user_purchase_history
  end

  test "subtracts existing purchase histories before checking balance" do
    wishlist = @user.user_wishlists.create!(name: "残高ぎりぎり", price: 400)
    purchased = @user.user_wishlists.create!(name: "購入済み", price: 200, is_purchased: true)
    purchased.create_user_purchase_history!(amount: 200, purchased_at: Time.current)
    create_log(user: @user, smoking_count: 0)

    assert_no_difference -> { UserPurchaseHistory.count } do
      assert_raises Purchase::Create::InsufficientBalance do
        Purchase::Create.call(user: @user, wishlist: wishlist)
      end
    end

    assert_not wishlist.reload.is_purchased
  end

  private

  def create_log(user:, smoking_count:, **snapshot_overrides)
    user.user_smoking_logs.create!(
      {
        smoked_on: Time.zone.today - 1.day,
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
