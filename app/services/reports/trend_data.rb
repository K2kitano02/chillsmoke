# frozen_string_literal: true

module Reports
  class TrendData
    DAYS = 30

    Result = Struct.new(
      :dates,
      :smoking_counts,
      :target_counts,
      :saved_yen,
      :recorded_count,
      :achieved_count,
      :confirmed_saved_yen,
      keyword_init: true
    ) do
      def labels
        dates.map { |date| date.strftime("%-m/%-d") }
      end

      def recorded?
        recorded_count.positive?
      end

      def confirmed_recorded?
        saved_yen.any? { |amount| !amount.nil? }
      end

      def recent_smoking_days
        dates.last(7).each_with_index.map do |date, index|
          source_index = dates.length - 7 + index
          {
            date: date,
            smoking_count: smoking_counts[source_index],
            target_count: target_counts[source_index]
          }
        end
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
      daily_saved_yen = values_for { |log, date| date == today ? nil : log&.saved_yen }

      Result.new(
        dates: dates,
        smoking_counts: values_for { |log, _date| log&.smoking_count },
        target_counts: values_for { |log, _date| log&.target_daily_cigarette_count_snapshot },
        saved_yen: daily_saved_yen,
        recorded_count: logs_by_date.size,
        achieved_count: logs_by_date.values.count(&:met_daily_target?),
        confirmed_saved_yen: daily_saved_yen.compact.sum
      )
    end

    private

    attr_reader :user, :today

    def dates
      @dates ||= ((today - (DAYS - 1).days)..today).to_a
    end

    def logs_by_date
      @logs_by_date ||= user.user_smoking_logs
        .where(smoked_on: dates.first..dates.last)
        .index_by(&:smoked_on)
    end

    def values_for
      dates.map do |date|
        yield logs_by_date[date], date
      end
    end
  end
end
