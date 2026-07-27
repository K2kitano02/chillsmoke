# frozen_string_literal: true

class UserSchedulesController < ApplicationController
  before_action :set_user_schedule, only: %i[edit update destroy toggle]

  def index
    @user_schedules = current_user.user_schedules.order(:scheduled_smoking_minutes, :id)
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

  def toggle
    @user_schedule.is_active = !@user_schedule.is_active?

    if @user_schedule.save
      respond_to_toggle(notice: "スケジュールの状態を切り替えました。")
    else
      respond_to_toggle(alert: @user_schedule.errors.full_messages.to_sentence, status: :unprocessable_entity)
    end
  end

  private

  def respond_to_toggle(notice: nil, alert: nil, status: :ok)
    @user_schedule.reload if @user_schedule.persisted?

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice if notice
        flash.now[:alert] = alert if alert

        render status: status
      end
      format.html do
        redirect_to user_schedules_path, notice: notice, alert: alert
      end
    end
  end

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
