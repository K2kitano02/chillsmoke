# frozen_string_literal: true

class UserSchedulesController < ApplicationController
  before_action :set_user_schedule, only: %i[edit update destroy]

  def index
    @user_schedules = current_user.user_schedules.order(:scheduled_smoking_time, :id)
  end

  def new
    @user_schedule = current_user.user_schedules.build(is_active: true)
  end

  def edit
  end

  def create
    @user_schedule = current_user.user_schedules.build(user_schedule_params)
    if @user_schedule.save
      redirect_to user_schedules_path, notice: "スケジュールを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_schedule.update(user_schedule_params)
      redirect_to user_schedules_path, notice: "スケジュールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_schedule.destroy!
    redirect_to user_schedules_path, notice: "スケジュールを削除しました。"
  end

  private

  def set_user_schedule
    @user_schedule = current_user.user_schedules.find(params[:id])
  end

  def user_schedule_params
    params.require(:user_schedule).permit(
      :scheduled_smoking_time,
      :label,
      :is_active
    )
  end
end
