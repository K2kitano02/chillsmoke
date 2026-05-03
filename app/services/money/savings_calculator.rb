# frozen_string_literal: true

module Money
  class SavingsCalculator
    Summary = Struct.new(:cumulative_saved_yen, :today_estimated_saved_yen, keyword_init: true)

    def self.call(user, today: Time.zone.today)
      new(user, today: today).call
    end

    def initialize(user, today:)
      @user = user
      @today = today
    end

    def call
      Summary.new(
        cumulative_saved_yen: cumulative_saved_yen,
        today_estimated_saved_yen: today_estimated_saved_yen
      )
    end

    private

    attr_reader :user, :today

    def cumulative_saved_yen
      user.user_smoking_logs.where("smoked_on < ?", today).sum(&:saved_yen)
    end

    def today_estimated_saved_yen
      today_log_for_display.saved_yen
    end

    def today_log_for_display
      user.user_smoking_logs.find_by(smoked_on: today) || build_virtual_today
    end

    def build_virtual_today
      setting = user.user_setting
      raise ActiveRecord::RecordNotFound, "user_setting is required" if setting.nil?

      user.user_smoking_logs.build(
        { smoked_on: today, smoking_count: 0 }.merge(
          UserSmokingLog.snapshot_attributes_from_user_setting(setting)
        )
      )
    end
  end
end
