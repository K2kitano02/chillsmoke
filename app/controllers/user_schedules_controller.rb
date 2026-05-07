# frozen_string_literal: true

class UserSchedulesController < ApplicationController
  def index
    @user_schedules = current_user.user_schedules.order(:scheduled_smoking_time, :id)
  end

  def new
    @user_schedule = current_user.user_schedules.build(is_active: true)
  end

  def create
    @user_schedule = current_user.user_schedules.build(user_schedule_params)
    if @user_schedule.save
      redirect_to user_schedules_path, notice: "スケジュールを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_schedule_params
    params.require(:user_schedule).permit(
      :scheduled_smoking_time,
      :label,
      :is_active
    )
  end
end
