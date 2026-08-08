# frozen_string_literal: true

module Reports
  class PaceData
    DAYS = 7
    PACE_DAYS = 30

    Result = Struct.new(
      :recorded_days,
      :average_smoking_count,
      :smoking_total,
      :target_total,
      :target_difference,
      :average_saved_yen,
      :thirty_day_saved_yen,
      keyword_init: true
    ) do
      def complete?
        recorded_days == PaceData::DAYS
      end

      def remaining_days
        PaceData::DAYS - recorded_days
      end
    end

    def self.call(user, today: Time.zone.today)
      new(user, today: today).call
    end

    def initialize(user, today:)
      @user = user
      @today = today
    end

    def call
      return incomplete_result unless logs.size == DAYS

      smoking_total = logs.sum(&:smoking_count)
      target_total = logs.sum(&:target_daily_cigarette_count_snapshot)
      saved_yen_total = logs.sum(&:saved_yen)

      Result.new(
        recorded_days: logs.size,
        average_smoking_count: smoking_total.fdiv(DAYS).ceil,
        smoking_total: smoking_total,
        target_total: target_total,
        target_difference: target_total - smoking_total,
        average_saved_yen: saved_yen_total.div(DAYS),
        thirty_day_saved_yen: (saved_yen_total * PACE_DAYS).div(DAYS)
      )
    end

    private

    attr_reader :user, :today

    def dates
      (today - DAYS.days)..(today - 1.day)
    end

    def logs
      @logs ||= user.user_smoking_logs.where(smoked_on: dates).to_a
    end

    def incomplete_result
      Result.new(recorded_days: logs.size)
    end
  end
end
