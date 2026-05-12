# frozen_string_literal: true

class UserWishlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :is_purchased, inclusion: { in: [ true, false ] }
end
