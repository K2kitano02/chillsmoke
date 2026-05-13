# frozen_string_literal: true

class UserWishlistsController < ApplicationController
  before_action :set_user_wishlist, only: :show

  def index
    @user_wishlists = current_user.user_wishlists.order(:is_purchased, :created_at, :id)
  end

  def show
  end

  def new
    @user_wishlist = current_user.user_wishlists.build
  end

  def create
    @user_wishlist = current_user.user_wishlists.build(user_wishlist_params)
    if @user_wishlist.save
      redirect_to user_wishlist_path(@user_wishlist), notice: "ウィッシュリストを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user_wishlist
    @user_wishlist = current_user.user_wishlists.find(params[:id])
  end

  def user_wishlist_params
    params.require(:user_wishlist).permit(:name, :price, :memo)
  end
end
