# frozen_string_literal: true

class UserSmokingLog < ApplicationRecord
  belongs_to :user

  validates :smoked_on, presence: true, uniqueness: { scope: :user_id }
  validates :smoking_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
