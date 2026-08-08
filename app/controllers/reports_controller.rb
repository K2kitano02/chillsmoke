# frozen_string_literal: true

class ReportsController < ApplicationController
  def show
    @user_setting = current_user.user_setting
    @trend_data = Reports::TrendData.call(current_user)
    @pace_data = Reports::PaceData.call(current_user)
    @today_estimated_saved_yen = Money::SavingsCalculator.today_estimated_saved_yen(current_user)
  end
end
