# frozen_string_literal: true

class UserWishlistsController < ApplicationController
  before_action :set_user_wishlist, only: :show

  def index
    @user_wishlists = current_user.user_wishlists.order(:is_purchased, :created_at, :id)
  end

  def show
  end

  private

  def set_user_wishlist
    @user_wishlist = current_user.user_wishlists.find(params[:id])
  end
end
