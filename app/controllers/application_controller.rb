class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Devise 用の sign_up / account_update に :name を通す（この before_action 未定義だと strong params に載らない）
  before_action :configure_permitted_parameters, if: :devise_controller?
  # 未ログインは全画面（Devise ・ Home#index 以外）で sign_in へ。Home#index はオンボーディング用に公開
  before_action :authenticate_user!, unless: :devise_controller?
  # ISSUE-21: ログイン済みで UserSetting が無いときは初期設定へ（Devise 画面では動かさない）
  before_action :ensure_user_setting_exists, unless: :devise_controller?
  allow_browser versions: :modern

  # ログイン成功後: 設定未作成なら初期設定へ。設定済みは stored_location または root（ダッシュボードは後続 ISSUE）
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.user_setting.blank?
      new_user_setting_path
    else
      stored_location_for(resource) || root_path
    end
  end

  # ログアウト後: オンボーディング（root）へ戻る
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  # current_user.user_setting を前提にできるようにする（nil のまま保護ページに入らせない）
  def ensure_user_setting_exists
    return unless user_signed_in?
    return if current_user.user_setting.present?

    redirect_to new_user_setting_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
