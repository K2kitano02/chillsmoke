# frozen_string_literal: true

module Money
  class BalanceQuery
    Result = Struct.new(:cumulative_saved_yen, :cumulative_spent_yen, :usable_yen, keyword_init: true)

    def self.call(user, today: Time.zone.today)
      new(user, today: today).call
    end

    def initialize(user, today:)
      @user = user
      @today = today
    end

    def call
      Result.new(
        cumulative_saved_yen: cumulative_saved_yen,
        cumulative_spent_yen: cumulative_spent_yen,
        usable_yen: cumulative_saved_yen - cumulative_spent_yen
      )
    end

    private

    attr_reader :user, :today

    def cumulative_saved_yen
      savings_summary.cumulative_saved_yen
    end

    def savings_summary
      @savings_summary ||= Money::SavingsCalculator.call(user, today: today)
    end

    def cumulative_spent_yen
      return 0 unless user.respond_to?(:user_purchase_histories)

      user.user_purchase_histories.sum(:amount)
    end
  end
end
