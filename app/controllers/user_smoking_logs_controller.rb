# frozen_string_literal: true

class UserSmokingLogsController < ApplicationController
  # ISSUE-32: 今日の +1 記録（保存操作。GET では当日行を作らない）
  def increment_today
    SmokingLog::Today.increment_persisted!(current_user)
    redirect_to dashboard_path, notice: "1本記録しました。"
  end
end
