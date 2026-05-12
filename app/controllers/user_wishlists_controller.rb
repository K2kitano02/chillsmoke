# frozen_string_literal: true

class UserWishlistsController < ApplicationController
  def index
    @user_wishlists = current_user.user_wishlists.order(:is_purchased, :created_at, :id)
  end
end
