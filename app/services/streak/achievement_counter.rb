# frozen_string_literal: true

module Streak
  class AchievementCounter
    def self.call(user, today: Time.zone.today)
      new(user, today: today).call
    end

    def initialize(user, today:)
      @user = user
      @today = today
    end

    def call
      streak = 0
      target_day = today - 1.day

      loop do
        log = logs_by_date[target_day]
        break if log.nil?
        break unless log.met_daily_target?

        streak += 1
        target_day -= 1.day
      end

      streak
    end

    private

    attr_reader :user, :today

    def logs_by_date
      @logs_by_date ||= user.user_smoking_logs
                            .where("smoked_on < ?", today)
                            .index_by(&:smoked_on)
    end
  end
end
