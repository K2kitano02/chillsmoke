class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Devise 用の sign_up / account_update に :name を通す（この before_action 未定義だと strong params に載らない）
  before_action :configure_permitted_parameters, if: :devise_controller?
  # ログイン・新規登録等は未認証で触れる。Devise コントローラは除外（ISSUE-11 と併用する定番形）
  before_action :authenticate_user!, unless: :devise_controller?
  allow_browser versions: :modern

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
