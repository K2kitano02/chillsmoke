# frozen_string_literal: true

class UserScheduleReflection < ApplicationRecord
  belongs_to :user_schedule

  validates :reflected_on, presence: true, uniqueness: { scope: :user_schedule_id }
end
