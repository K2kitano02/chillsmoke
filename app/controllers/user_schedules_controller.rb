# frozen_string_literal: true

class UserSchedulesController < ApplicationController
  def index
    @user_schedules = current_user.user_schedules.order(:scheduled_smoking_time, :id)
  end
end
