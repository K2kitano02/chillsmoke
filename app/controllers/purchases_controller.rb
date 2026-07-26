# frozen_string_literal: true

class PurchasesController < ApplicationController
  def create
    wishlist = current_user.user_wishlists.find(params[:id])

    Purchase::Create.call(user: current_user, wishlist: wishlist)

    respond_to_purchase(wishlist, notice: "購入しました。")
  rescue Purchase::Create::AlreadyPurchased
    respond_to_purchase(wishlist, alert: "すでに購入済みです。", status: :unprocessable_entity)
  rescue Purchase::Create::InsufficientBalance
    respond_to_purchase(wishlist, alert: insufficient_balance_message(wishlist), status: :unprocessable_entity)
  end

  private

  def respond_to_purchase(wishlist, notice: nil, alert: nil, status: :ok)
    prepare_wishlist_detail(wishlist)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice if notice
        flash.now[:alert] = alert if alert

        render status: status
      end
      format.html do
        redirect_to user_wishlist_path(wishlist), notice: notice, alert: alert
      end
    end
  end

  def prepare_wishlist_detail(wishlist)
    @user_wishlist = wishlist.reload
    @balance = Money::BalanceQuery.call(current_user)
    @user_purchase_history = @user_wishlist.user_purchase_history
    @header_balance = @balance
    @header_streak_count = Streak::AchievementCounter.call(current_user)
  end

  def insufficient_balance_message(wishlist)
    balance = Money::BalanceQuery.call(current_user)
    shortage_yen = wishlist.price - balance.usable_yen

    "使用可能金額が不足しています。あと#{helpers.number_with_delimiter(shortage_yen)}円必要です。" \
      "現在の使用可能金額は#{helpers.number_with_delimiter(balance.usable_yen)}円です。"
  end
end
