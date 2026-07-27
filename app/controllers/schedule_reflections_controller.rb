# frozen_string_literal: true

class ScheduleReflectionsController < ApplicationController
  def create
    result = ScheduleReflection::Today.call(current_user)
    notice =
      if result.reflected_count.positive?
        "スケジュールを#{result.reflected_count}件反映しました。"
      else
        "本日分の未反映スケジュールはありません。"
      end

    prepare_dashboard_summary

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = notice }
      format.html { redirect_to dashboard_path, notice: notice }
    end
  end

  private

  def prepare_dashboard_summary
    @today_smoking_log = SmokingLog::Today.for_display(current_user)
    @daily_target_count = @today_smoking_log.target_daily_cigarette_count_snapshot
    @remaining_count = [ @daily_target_count - @today_smoking_log.smoking_count, 0 ].max
    @savings_summary = Money::SavingsCalculator.call(current_user)
    @header_balance = Money::BalanceQuery.call(current_user)
    @header_streak_count = Streak::AchievementCounter.call(current_user)
  end
end
