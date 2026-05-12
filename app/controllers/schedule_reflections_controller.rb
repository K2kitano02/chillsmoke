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

    redirect_to dashboard_path, notice: notice
  end
end
