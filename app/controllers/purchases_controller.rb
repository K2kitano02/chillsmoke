# frozen_string_literal: true

class PurchasesController < ApplicationController
  def create
    wishlist = current_user.user_wishlists.find(params[:id])

    Purchase::Create.call(user: current_user, wishlist: wishlist)

    redirect_to user_wishlist_path(wishlist), notice: "購入しました。"
  rescue Purchase::Create::AlreadyPurchased
    redirect_to user_wishlist_path(wishlist), alert: "すでに購入済みです。"
  rescue Purchase::Create::InsufficientBalance
    redirect_to user_wishlist_path(wishlist), alert: insufficient_balance_message(wishlist)
  end

  private

  def insufficient_balance_message(wishlist)
    balance = Money::BalanceQuery.call(current_user)
    shortage_yen = wishlist.price - balance.usable_yen

    "使用可能金額が不足しています。あと#{helpers.number_with_delimiter(shortage_yen)}円必要です。" \
      "現在の使用可能金額は#{helpers.number_with_delimiter(balance.usable_yen)}円です。"
  end
end
