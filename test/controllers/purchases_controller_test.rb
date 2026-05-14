# frozen_string_literal: true

require "test_helper"

class PurchasesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインでは購入できない" do
    post purchase_user_wishlist_url(user_wishlists(:watch))

    assert_redirected_to new_user_session_url
  end

  test "create はログインユーザーの wishlist を購入して詳細へ戻る" do
    user = users(:one)
    sign_in user
    wishlist = user.user_wishlists.create!(name: "イヤホン", price: 250)
    create_log(user: user, smoking_count: 10)

    assert_difference -> { UserPurchaseHistory.count }, 1 do
      post purchase_user_wishlist_url(wishlist)
    end

    assert_redirected_to user_wishlist_url(wishlist)
    wishlist.reload
    assert wishlist.is_purchased
    assert_equal 250, wishlist.user_purchase_history.amount
    assert_equal wishlist, wishlist.user_purchase_history.user_wishlist
  end

  test "create は他ユーザーの wishlist なら 404 を返して購入しない" do
    sign_in users(:one)
    wishlist = user_wishlists(:purchased_bag)

    assert_no_difference -> { UserPurchaseHistory.count } do
      post purchase_user_wishlist_url(wishlist)
    end

    assert_response :not_found
  end

  test "create は残高不足なら購入しない" do
    user = users(:one)
    sign_in user
    wishlist = user.user_wishlists.create!(name: "高額品", price: 30_000)
    create_log(user: user, smoking_count: 10)

    assert_no_difference -> { UserPurchaseHistory.count } do
      post purchase_user_wishlist_url(wishlist)
    end

    assert_redirected_to user_wishlist_url(wishlist)
    assert_match(/使用可能金額が不足しています。/, flash[:alert])
    assert_match(/あと29,750円必要です。/, flash[:alert])
    assert_match(/現在の使用可能金額は250円です。/, flash[:alert])
    assert_not wishlist.reload.is_purchased
  end

  test "create は購入済みなら購入しない" do
    user = users(:two)
    sign_in user
    wishlist = user_wishlists(:purchased_bag)
    create_log(user: user, smoking_count: 0, pack_price_snapshot: 20_000)

    assert_no_difference -> { UserPurchaseHistory.count } do
      post purchase_user_wishlist_url(wishlist)
    end

    assert_redirected_to user_wishlist_url(wishlist)
    assert_equal "すでに購入済みです。", flash[:alert]
    assert wishlist.reload.is_purchased
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
