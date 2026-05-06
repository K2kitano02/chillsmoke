# frozen_string_literal: true

class UserSchedule < ApplicationRecord
  belongs_to :user

  validates :scheduled_smoking_time, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }
end
