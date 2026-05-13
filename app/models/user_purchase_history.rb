# frozen_string_literal: true

class UserPurchaseHistory < ApplicationRecord
  belongs_to :user_wishlist

  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :purchased_at, presence: true
  validates :user_wishlist_id, uniqueness: true
end
