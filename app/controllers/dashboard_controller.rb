class DashboardController < ApplicationController
  def index
    @today_smoking_log = SmokingLog::Today.for_display(current_user)
  end
end
