class UserSettingsController < ApplicationController
  # 未設定ユーザーが new/create に届くため、ここだけは ensure をかけない（ループ防止）
  skip_before_action :ensure_user_setting_exists, only: %i[new create]
  # 既に設定があるユーザーは 2 件目作成フローに入れない（URL 直叩き対策）。編集は ISSUE-23 の edit へ寄せる想定
  before_action :redirect_if_user_setting_exists, only: %i[new create]

  def new
    @user_setting = current_user.build_user_setting
  end

  def create
    @user_setting = current_user.build_user_setting(user_setting_params)
    if @user_setting.save
      redirect_to dashboard_path, notice: "初期設定を保存しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_user_setting_exists
    return if current_user.user_setting.blank?

    redirect_to dashboard_path, alert: "初期設定はすでに登録されています。"
  end

  def user_setting_params
    params.require(:user_setting).permit(
      :baseline_daily_cigarette_count,
      :target_daily_cigarette_count,
      :pack_price,
      :cigarettes_per_pack,
      :is_oni_mode
    )
  end
end
