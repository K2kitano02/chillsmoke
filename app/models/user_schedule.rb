# frozen_string_literal: true

class UserSchedule < ApplicationRecord
  belongs_to :user
  has_many :user_schedule_reflections, dependent: :destroy

  validates :scheduled_smoking_time, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }
end
