# frozen_string_literal: true

class UserSchedule < ApplicationRecord
  belongs_to :user
  has_many :user_schedule_reflections, dependent: :destroy

  validates :scheduled_smoking_minutes,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 1440 }
  validates :scheduled_smoking_time, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }

  def scheduled_smoking_time
    return if scheduled_smoking_minutes.blank?

    format("%02d:%02d", scheduled_smoking_minutes / 60, scheduled_smoking_minutes % 60)
  end

  def scheduled_smoking_time=(value)
    self.scheduled_smoking_minutes = parse_time_to_minutes(value)
  end

  private

  def parse_time_to_minutes(value)
    return nil if value.blank?

    match = value.to_s.match(/\A(?<hour>\d{1,2}):(?<minute>\d{2})(?::\d{2})?\z/)
    return nil unless match

    hour = match[:hour].to_i
    minute = match[:minute].to_i
    return nil unless hour.between?(0, 23) && minute.between?(0, 59)

    (hour * 60) + minute
  end
end
