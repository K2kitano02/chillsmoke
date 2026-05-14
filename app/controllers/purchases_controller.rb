# frozen_string_literal: true

class PurchasesController < ApplicationController
  def create
    wishlist = current_user.user_wishlists.find(params[:id])

    Purchase::Create.call(user: current_user, wishlist: wishlist)

    redirect_to user_wishlist_path(wishlist), notice: "購入しました。"
  rescue Purchase::Create::AlreadyPurchased
    redirect_to user_wishlist_path(wishlist), alert: "すでに購入済みです。"
  rescue Purchase::Create::InsufficientBalance
    redirect_to user_wishlist_path(wishlist), alert: "使用可能金額が不足しています。"
  end
end
