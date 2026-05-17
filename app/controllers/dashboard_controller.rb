class DashboardController < ApplicationController
  def index
    @today_smoking_log = SmokingLog::Today.for_display(current_user)
    @daily_target_count = @today_smoking_log.target_daily_cigarette_count_snapshot
    @remaining_count = [ @daily_target_count - @today_smoking_log.smoking_count, 0 ].max
    @savings_summary = Money::SavingsCalculator.call(current_user)
    @balance = Money::BalanceQuery.call(current_user)
  end
end
